module sync_pos_neg_edge_detector (
    input wire i_clk,
    input wire i_rstb,
    input wire i_detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    reg [1:0] edge_stage; // 0: idle, 1: rising, 2: falling
    reg o_positive;
    reg o_negative;

    always @(posedge i_clk) begin
        if (i_rstb) begin
            o_positive <= 0;
            o_negative <= 0;
            edge_stage <= 0;
        end else begin
            if (i_detection_signal) begin
                if (edge_stage == 1'b0) begin
                    o_positive <= 1;
                    edge_stage <= 1'b1;
                end else if (edge_stage == 1'b1) begin
                    o_positive <= 0;
                    edge_stage <= 1'b2;
                end
            end
            if (edge_stage == 1'b2) begin
                o_negative <= 1;
                edge_stage <= 1'b0;
            end
        end
    end

    always @(*) begin
        if (edge_stage == 1'b1) o_positive = 1;
        if (edge_stage == 1'b2) o_negative = 1;
    end

    assign o_positive_edge_detected = o_positive;
    assign o_negative_edge_detected = o_negative;

endmodule
