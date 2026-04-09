module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 1
)(
    input  logic src_clock,
    input  logic des_clock,
    input  logic rst_in,
    input  logic [NUM_CHANNELS-1:0] src_pulse,
    output logic [NUM_CHANNELS-1:0] des_pulse
);

    // In the source clock domain, generate a toggle for each channel.
    // When a single-cycle pulse (src_pulse[i]) is detected, the corresponding toggle flips.
    logic [NUM_CHANNELS-1:0] src_toggle;

    // In the destination clock domain, we transfer and synchronize the toggle signal.
    // We use a two-stage synchronizer (two flops) followed by an additional flop,
    // and then detect the rising edge between the last two stages.
    logic [NUM_CHANNELS-1:0] sync0, sync1, sync2;

    // Generate source-domain toggle generation for each channel.
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : gen_src_toggle
            always_ff @(posedge src_clock or posedge rst_in) begin
                if (rst_in)
                    src_toggle[i] <= 1'b0;
                else if (src_pulse[i])
                    src_toggle[i] <= ~src_toggle[i];
            end
        end
    endgenerate

    // Synchronize the toggle signal from the source domain to the destination domain.
    // For each channel, we use a two-flop synchronizer followed by an extra flop.
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : gen_sync_chain
            // First synchronizer stage: two flops.
            always_ff @(posedge des_clock or posedge rst_in) begin
                if (rst_in) begin
                    sync0[i] <= 1'b0;
                    sync1[i] <= 1'b0;
                end else begin
                    sync0[i] <= src_toggle[i];  // Transfer the toggle from src domain.
                    sync1[i] <= sync0[i];
                end
            end

            // Second synchronizer stage: one additional flop.
            always_ff @(posedge des_clock or posedge rst_in) begin
                if (rst_in)
                    sync2[i] <= 1'b0;
                else
                    sync2[i] <= sync1[i];
            end
        end
    endgenerate

    // Detect the rising edge of the synchronized toggle signal.
    // The XOR of sync2 and sync1 generates a pulse when the toggle transitions.
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : gen_edge_detect
            assign des_pulse[i] = sync2[i] ^ sync1[i];
        end
    endgenerate

endmodule