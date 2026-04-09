module sync_pos_neg_edge_detector(
  input wire i_clk,
  input wire i_rstb,
  input wire i_detection_signal,
  output wire o_positive_edge_detected,
  output wire o_negative_edge_detected
);

  reg [1:0] state; // State register to track the current state

  always @(posedge i_clk or posedge i_rstb) begin
    if (i_rstb == 1'b0) begin
      state <= 2'b00; // Reset state
    end else begin
      case (state)
        2'b00: begin
          if (i_detection_signal == 1'b1) begin
            state <= 2'b01; // Positive edge detected, wait for next clock cycle
          end
        end
        2'b01: begin
          o_positive_edge_detected <= 1'b1; // Output positive edge detection
          state <= 2'b10; // Wait for negative edge detection
        end
        2'b10: begin
          if (i_detection_signal == 1'b0) begin
            state <= 2'b11; // Negative edge detected, wait for next clock cycle
          end
        end
        2'b11: begin
          o_negative_edge_detected <= 1'b1; // Output negative edge detection
          state <= 2'b00; // Reset state
        end
      endcase
    end
  end

endmodule