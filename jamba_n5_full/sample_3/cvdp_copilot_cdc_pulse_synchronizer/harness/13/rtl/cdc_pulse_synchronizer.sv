module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 4
) (
    input  logic src_clock,
    input  logic des_clock,
    input  logic rst_in,
    input  logic [(NUM_CHANNELS-1:0)] src_pulse,
    output logic [(NUM_CHANNELS-1:0)] des_pulse
);

    logic pls_toggle;
    logic pls_toggle_synca, pls_toggle_syncb, pls_toggle_syncc;
    logic rst_src_sync;
    logic rst_des_sync;
    logic rst_src_synca, rst_src_syncb;
    logic rst_des_synca, rst_des_syncb;

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_synca <= 1'b1;
            rst_src_syncb <= 1'b1;
        end else begin
            rst_src_synca <= 1'b0;
            rst_src_syncb <= rst_src_synca;
        end
    end

    assign rst_src_sync = rst_src_syncb;

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_des_synca <= 1'b1;
            rst_des_syncb <= 1'b1;
        end else begin
            rst_des_synca <= 1'b0;
            rst_des_syncb <= rst_des_synca;
        end
    end

    assign rst_des_sync = rst_des_syncb;

    genvar i;
    generate
        for (genvar i = 0; i < NUM_CHANNELS; i++) begin : channel_inst
            always_ff @(posedge src_clock or posedge rst_src_sync) begin
                if (rst_src_sync) begin
                    pls_toggle <= 1'b0;
                end else if (src_pulse[i]) begin
                    pls_toggle <= ~pls_toggle;
                end
            end

            always_ff @(posedge des_clock or posedge rst_des_sync) begin
                if (rst_des_sync) begin
                    pls_toggle_synca <= 1'b0;
                    pls_toggle_syncb <= 1'b0;
                end else begin
                    pls_toggle_synca <= pls_toggle;
                    pls_toggle_syncb <= pls_toggle_synca;
                end
            end

            always_ff @(posedge des_clock or posedge rst_des_sync) begin
                if (rst_des_sync) begin
                    pls_toggle_syncc <= 1'b0;
                end else begin
                    pls_toggle_syncc <= pls_toggle_syncb;
                end
            end

            assign des_pulse[i] = pls_toggle_syncc ^ pls_toggle_syncb;
        endfor
    endgenerate

endmodule
