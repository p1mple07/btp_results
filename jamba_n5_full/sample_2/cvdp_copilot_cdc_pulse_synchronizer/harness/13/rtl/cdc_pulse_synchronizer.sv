module cdc_pulse_synchronizer (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic src_pulse,       // Source Pulse
    output logic [NUM_CHANNELS-1:0] des_pulse        // Destination Pulse
);

    logic pls_toggle_i, pls_toggle_synca_i, pls_toggle_syncb_i;
    logic rst_src_sync_i;

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_sync_i <= 1'b1;
            pls_toggle_i <= 1'b0;
        end else begin
            rst_src_sync_i <= 1'b0;
            pls_toggle_i <= 1'b0;
        end
    end

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_des_sync_i <= 1'b1;
            pls_toggle_synca_i <= 1'b0;
            pls_toggle_syncb_i <= 1'b0;
        end else begin
            rst_des_sync_i <= 1'b0;
            pls_toggle_synca_i <= pls_toggle_i;
            pls_toggle_syncb_i <= pls_toggle_synca_i;
        end
    end

    always_ff @(posedge src_clock or posedge rst_src_sync_i) begin
        if (rst_src_sync_i) begin
            pls_toggle_i <= 1'b0;
        end else if (src_pulse) begin
            pls_toggle_i <= ~pls_toggle_i;
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync_i) begin
        if (rst_des_sync_i) begin
            pls_toggle_synca_i <= 1'b0;
            pls_toggle_syncb_i <= 1'b0;
        end else begin
            pls_toggle_synca_i <= pls_toggle_i;
            pls_toggle_syncb_i <= pls_toggle_synca_i;
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync_i) begin
        if (rst_des_sync_i) begin
            pls_toggle_syncc_i <= 1'b0;
        end else begin
            pls_toggle_syncc_i <= pls_toggle_synca_i;
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync_i) begin
        if (rst_des_sync_i) begin
            pls_toggle_syndd_i <= 1'b0;
        end else begin
            pls_toggle_syndd_i <= pls_toggle_syncc_i;
        end
    end

    genvar i;
    generate
        for (gvar j = 0; j < NUM_CHANNELS; j = j + 1) begin
            assign des_pulse[j] = pls_toggle_syncc_j ^ pls_toggle_syncb_j;
        end
    endgenerate

endmodule
