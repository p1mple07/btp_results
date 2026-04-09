module sync_pos_neg_edge_detector (
  input wire i_clk,
  input wire i_rstb,
  input wire i_detection_signal,
  output reg o_positive_edge_detected,
  output reg o_negative_edge_detected
);

always @(posedge i_clk or posedge i_rstb) begin
  if (i_rstb == 1'b0) begin
    // Reset behavior
    o_positive_edge_detected <= 1'b0;
    o_negative_edge_detected <= 1'b0;
  end else begin
    // Edge detection behavior
    if (i_detection_signal!= o_positive_edge_detected) begin
      o_positive_edge_detected <= i_detection_signal;
    end
    if (i_detection_signal!= o_negative_edge_detected) begin
      o_negative_edge_detected <= i_detection_signal;
    end
  end
end

endmodule