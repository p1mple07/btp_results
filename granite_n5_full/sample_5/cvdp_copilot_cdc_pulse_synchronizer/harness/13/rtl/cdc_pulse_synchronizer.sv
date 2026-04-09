module cdc_pulse_synchronizer (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic src_pulse[$],   // Vector of single-cycle pulse signals in the source clock domain
    output logic des_pulse[$]    // Vector of synchronized single-cycle pulse signals in the destination clock domain
);

    localparam NUM_CHANNELS = $size(src_pulse);

    logic pls_toggle[$];
    logic pls_toggle_synca[$], pls_toggle_syncb[$];
    logic rst_src_sync[$], rst_des_sync[$];
    logic rst_src_synca[$], rst_src_syncb[$];
    logic rst_des_synca[$], rst_des_syncb[$];

    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i++) begin : GEN_PULSE_SYNC
            always_ff @(posedge src_clock or posedge rst_in) begin
                if (rst_in) begin
                    pls_toggle[i] <= 1'b1;
                end else if (src_pulse[i]) begin
                    pls_toggle[i] <= ~pls_toggle[i];
                end
            end

            always_ff @(posedge des_clock or posedge rst_in) begin
                if (rst_in) begin
                    pls_toggle_synca[i] <= 1'b0;
                    pls_toggle_syncb[i] <= 1'b0;
                end else begin
                    pls_toggle_synca[i] <= pls_toggle[i];
                    pls_toggle_syncb[i] <= pls_toggle_synca[i];
                end
            end

            always_ff @(posedge des_clock or posedge rst_des_sync[i]) begin
                if (rst_des_sync[i]) begin
                    pls_toggle_syncc[i] <= 1'b0;
                end else begin
                    pls_toggle_syncc[i] <= pls_toggle_syncb[i];
                end
            end

            assign des_pulse[i] = pls_toggle_syncc[i] ^ pls_toggle_syncb[i];

        end
    endgenerate

endmodule