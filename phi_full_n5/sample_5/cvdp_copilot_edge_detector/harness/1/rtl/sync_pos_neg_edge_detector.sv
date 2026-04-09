module sync_pos_neg_edge_detector(
    input wire i_clk,
    input wire i_rstb,
    input wire i_detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    reg [1:0] state;
    always @(posedge i_clk or posedge i_rstb) begin
        if (i_rstb) begin
            state <= 2'b00;
            o_positive_edge_detected <= 0;
            o_negative_edge_detected <= 0;
        end else begin
            case (state)
                2'b00: begin
                    if (i_detection_signal) begin
                        state <= 2'b01;
                        o_positive_edge_detected <= 1;
                        o_negative_edge_detected <= 0;
                    end
                end
                2'b01: begin
                    if (!i_detection_signal) begin
                        state <= 2'b00;
                        o_positive_edge_detected <= 0;
                        o_negative_edge_detected <= 0;
                    end
                end
                default: state <= 2'b00;
            endcase
        end
    end

endmodule
