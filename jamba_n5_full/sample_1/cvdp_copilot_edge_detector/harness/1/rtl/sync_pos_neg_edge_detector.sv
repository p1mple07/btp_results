module sync_pos_neg_edge_detector (
    input wire i_clk,
    input wire i_rstb,
    input wire i_detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    localparam POSITIVE_EDGE = 1'b1;
    localparam NEGATIVE_EDGE = 1'b0;
    localparam IDLE = 1'b0;

    reg [2:0] state;
    reg pos_detect, neg_detect;

    always @(posedge i_clk or negedge i_rstb or i_detection_signal) begin
        if (i_rstb) begin
            state <= IDLE;
            pos_detect <= 0;
            neg_detect <= 0;
            o_positive_edge_detected <= 1'b0;
            o_negative_edge_detected <= 1'b0;
        end else begin
            if (state == IDLE) begin
                pos_detect <= 0;
                neg_detect <= 0;
                o_positive_edge_detected <= 1'b0;
                o_negative_edge_detected <= 1'b0;
            end else {
                pos_detect = (i_detection_signal && !pos_detect);
                neg_detect = (i_detection_signal && !neg_detect);
                if (pos_detect) o_positive_edge_detected = 1'b1;
                else if (neg_detect) o_negative_edge_detected = 1'b1;
            }
        }
    end

endmodule
