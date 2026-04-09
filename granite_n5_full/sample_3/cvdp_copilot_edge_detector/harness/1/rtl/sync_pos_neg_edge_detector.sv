module sync_pos_neg_edge_detector(
  input wire i_clk,
  input wire i_rstb,
  input wire i_detection_signal,
  output reg o_positive_edge_detected,
  output reg o_negative_edge_detected
);

  always @(posedge i_clk or posedge i_rstb) begin
    if (i_rstb == 1'b0) begin
      o_positive_edge_detected <= 1'b0;
      o_negative_edge_detected <= 1'b0;
    end else begin
      // Detect positive edge
      if (i_detection_signal!= i_detection_signal_previous) begin
        o_positive_edge_detected <= 1'b1;
      end else begin
        o_positive_edge_detected <= 1'b0;
      end

      // Detect negative edge
      if (i_detection_signal_previous!= i_detection_signal) begin
        o_negative_edge_detected <= 1'b1;
      end else begin
        o_negative_edge_detected <= 1'b0;
      end
    end
  end

endmodule