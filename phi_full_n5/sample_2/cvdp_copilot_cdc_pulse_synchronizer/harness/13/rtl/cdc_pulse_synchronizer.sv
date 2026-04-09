module cdc_pulse_synchronizer #(parameter NUM_CHANNELS = 4) (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic [NUM_CHANNELS-1:0] src_pulse,       // Source Pulse Vector
    output logic [NUM_CHANNELS-1:0] des_pulse        // Destination Pulse Vector
);

    logic [NUM_CHANNELS-1:0] pls_toggle_synca, pls_toggle_syncb, pls_toggle_syncc;
    logic [NUM_CHANNELS-1:0] rst_src_sync, rst_des_sync;

    // Synchronize source pulse toggles
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_sync <= (NUM_CHANNELS - 1'b0);
        end else begin
            rst_src_sync <= rst_src_sync + 1'b1;
        end
    end

    // Synchronize destination pulse toggles
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_des_sync <= (NUM_CHANNELS - 1'b0);
        end else begin
            rst_des_sync <= rst_des_sync + 1'b1;
        end
    end

    // Synchronize each channel
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin
            // Source domain double-flop synchronizer
            always_ff @(posedge src_clock or posedge rst_in) begin
                if (rst_in) begin
                    pls_toggle_synca[i] <= 1'b0;
                    pls_toggle_syncb[i] <= 1'b0;
                end else begin
                    pls_toggle_synca[i] <= ~pls_toggle_synca[i];
                end
            end

            // Destination domain double-flop synchronizer
            always_ff @(posedge des_clock or posedge rst_des_sync) begin
                if (rst_des_sync) begin
                    pls_toggle_syncc[i] <= 1'b0;
                end else begin
                    pls_toggle_syncc[i] <= pls_toggle_syncb[i];
                end
            end

            // Generate destination pulse for each channel
            assign des_pulse[i] = pls_toggle_syncc[i] ^ pls_toggle_syncb[i];
        end
    endgenerate

endmodule