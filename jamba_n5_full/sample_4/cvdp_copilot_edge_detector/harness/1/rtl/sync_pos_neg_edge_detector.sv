module sync_pos_neg_edge_detector (
    input wire i_clk,
    input wire i_rstb,
    input wire i_detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    reg [1:0] state; // 0: idle, 1: rising, 2: falling
    reg positive_edge;
    reg negative_edge;

    always @(posedge i_clk or negedge i_rstb) begin
        if (i_rstb)
            state <= 0;
            positive_edge <= 0;
            negative_edge <= 0;
            o_positive_edge_detected <= 0;
            o_negative_edge_detected <= 0;
        else
            if (state == 0) begin
                if (i_detection_signal == 1'b1)
                    state <= 1;
                    positive_edge <= 1;
                else
                    next_state = 0;
            end else if (state == 1) begin
                if (i_detection_signal == 1'b0)
                    state <= 2;
                    negative_edge <= 1;
                else
                    state <= 0;
            end else if (state == 2) begin
                state <= 0;
                negative_edge <= 0;
            end
        end
    end

    always @(*) begin
        if (positive_edge)
            o_positive_edge_detected <= 1;
        else if (negative_edge)
            o_negative_edge_detected <= 1;
    end

endmodule
