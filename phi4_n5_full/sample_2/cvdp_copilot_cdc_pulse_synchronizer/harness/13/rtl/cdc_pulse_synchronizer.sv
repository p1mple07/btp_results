module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 1
) (
    input  logic src_clock,
    input  logic des_clock,
    input  logic rst_in,
    input  logic [NUM_CHANNELS-1:0] src_pulse,
    output logic [NUM_CHANNELS-1:0] des_pulse
);

    // Internal signal: toggle for each channel generated in the source clock domain.
    logic [NUM_CHANNELS-1:0] src_toggle;

    // Synchronization registers in the destination clock domain.
    // These registers form a two-stage synchronizer chain per channel.
    logic [NUM_CHANNELS-1:0] des_toggle_sync0;
    logic [NUM_CHANNELS-1:0] des_toggle_sync1;
    logic [NUM_CHANNELS-1:0] des_toggle_sync2;

    // Source domain: Generate a toggle signal for each channel.
    // On a rising edge of src_clock, if the corresponding src_pulse is asserted,
    // the toggle is inverted. This converts a single-cycle pulse into a toggle.
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in)
            src_toggle <= '0;
        else begin
            for (int i = 0; i < NUM_CHANNELS; i++) begin
                if (src_pulse[i])
                    src_toggle[i] <= ~src_toggle[i];
                // Else, leave the toggle unchanged.
            end
        end
    end

    // Destination domain: Synchronize the toggle signal and detect its rising edge
    // to generate a single-cycle pulse for each channel.
    // The synchronization chain introduces a maximum of three clock cycles latency.
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i++) begin : sync_channel
            // First stage of the synchronizer.
            always_ff @(posedge des_clock or posedge rst_in) begin
                if (rst_in) begin
                    des_toggle_sync0[i] <= 1'b0;
                    des_toggle_sync1[i] <= 1'b0;
                end else begin
                    des_toggle_sync0[i] <= src_toggle[i];
                    des_toggle_sync1[i] <= des_toggle_sync0[i];
                end
            end

            // Second stage of the synchronizer.
            always_ff @(posedge des_clock or posedge rst_in) begin
                if (rst_in)
                    des_toggle_sync2[i] <= 1'b0;
                else
                    des_toggle_sync2[i] <= des_toggle_sync1[i];
            end

            // Generate the destination pulse by detecting the rising edge of the synchronized toggle.
            // The pulse is asserted for one clock cycle when des_toggle_sync2 and des_toggle_sync1 differ.
            assign des_pulse[i] = des_toggle_sync2[i] ^ des_toggle_sync1[i];
        end
    endgenerate

endmodule