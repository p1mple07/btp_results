module clock_divider (input logic clk, rst_n, [1:0] sel, output logic clk_out);

  // Define internal signals
  logic [1:0] counter;
  logic [1:0] divisor;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset behavior
      counter <= 0;
      divisor <= 0;
      clk_out <= 1'b0;
    end else begin
      // Clock division functionality
      case(sel)
        2'b00: begin
          divisor <= 2;
          counter <= counter + 1;
        end
        2'b01: begin
          divisor <= 4;
          counter <= counter + 1;
        end
        2'b10: begin
          divisor <= 8;
          counter <= counter + 1;
        end
        default: begin
          // Out-of-range sel value
          clk_out <= 1'b0;
        end
      endcase

      if (counter == divisor) begin
        clk_out <= ~clk_out;
        counter <= 0;
      end
    end
  end

endmodule