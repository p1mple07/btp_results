module sync_pos_neg_edge_detector(
  input wire i_clk,
  input wire i_rstb,
  input wire i_detection_signal,
  output reg o_positive_edge_detected,
  output reg o_negative_edge_detected
);

  always @(posedge i_clk) begin
    if (!i_rstb) begin
      o_positive_edge_detected <= 0;
      o_negative_edge_detected <= 0;
    end else begin
      if (i_detection_signal &&!o_positive_edge_detected) begin
        o_positive_edge_detected <= 1;
        #1 o_positive_edge_detected <= 0; // #1 ensures the edge is captured for one clock cycle
      end

      if (!i_detection_signal &&!o_negative_edge_detected) begin
        o_negative_edge_detected <= 1;
        #1 o_negative_edge_detected <= 0; // #1 ensures the edge is captured for one clock cycle
      end
    end
  end

endmodule