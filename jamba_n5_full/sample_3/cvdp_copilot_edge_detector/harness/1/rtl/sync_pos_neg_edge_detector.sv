module sync_pos_neg_edge_detector (
    input wire i_clk,
    input wire i_rstb,
    input wire i_detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    always @(posedge i_clk or negedge i_rstb) begin
        if (i_rstb) begin
            o_positive_edge_detected <= 0;
            o_negative_edge_detected <= 0;
        end else begin
            if (i_detection_signal) begin
                if (posedge i_detection_signal) begin
                    o_positive_edge_detected = 1;
                end else if (negedge i_detection_signal) begin
                    o_negative_edge_detected = 1;
                end
            end
        end
    end

endmodule
