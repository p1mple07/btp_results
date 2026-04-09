module sync_pos_neg_edge_detector(
    input  wire i_clk,
    input  wire i_rstb,         // asynchronous reset, active low
    input  wire i_detection_signal,
    output reg  o_positive_edge_detected,
    output reg  o_negative_edge_detected
);

  // Register to hold the previous state of the detection signal
  reg prev_signal;

  always @(posedge i_clk or negedge i_rstb) begin
    if (!i_rstb) begin
      // Asynchronous reset: clear outputs and previous state
      prev_signal             <= 1'b0;
      o_positive_edge_detected <= 1'b0;
      o_negative_edge_detected <= 1'b0;
    end else begin
      // Detect positive edge: transition from 0 to 1
      if (!prev_signal && i_detection_signal) begin
        o_positive_edge_detected <= 1'b1;
      end else begin
        o_positive_edge_detected <= 1'b0;
      end

      // Detect negative edge: transition from 1 to 0
      if (prev_signal && !i_detection_signal) begin
        o_negative_edge_detected <= 1'b1;
      end else begin
        o_negative_edge_detected <= 1'b0;
      end

      // Update the previous state
      prev_signal <= i_detection_signal;
    end
  end

endmodule