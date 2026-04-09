module clock_divider (
  input logic clk,        // Input clock
  input logic rst_n,     // Active-low asynchronous reset
  input logic [1:0] sel,  // Selection input for clock division factor
  output logic clk_out   // Output clock signal
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      // Reset behavior when rst_n is de-asserted
      case(sel)
        2'b00: clk_out <= 1'b0;
        2'b01: clk_out <= 1'b0;
        2'b10: clk_out <= 1'b0;
        default: clk_out <= 1'b0; // Hold at 0 for out-of-range sel values
      endcase
    end else begin
      // Clock division functionality based on sel value
      unique case(sel)
        2'b00: clk_out <= clk;
        2'b01: clk_out <= clk >> 1;
        2'b10: clk_out <= clk >> 2;
        default: clk_out <= clk; // Hold at current value for out-of-range sel values
      endcase
    end
  end

endmodule