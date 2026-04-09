module clock_divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [1:0]   sel,
    output logic         clk_out
);

  // 3-bit counter is sufficient for division factors up to 8
  logic [2:0] counter;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter  <= 3'd0;
      clk_out  <= 1'b0;
    end
    else begin
      case (sel)
        2'b00: begin // Divide by 2: toggle every 2 cycles
          if (counter == 1) begin
            counter <= 3'd0;
            clk_out <= ~clk_out;
          end
          else begin
            counter <= counter + 1;
          end
        end
        2'b01: begin // Divide by 4: toggle every 4 cycles
          if (counter == 3) begin
            counter <= 3'd0;
            clk_out <= ~clk_out;
          end
          else begin
            counter <= counter + 1;
          end
        end
        2'b10: begin // Divide by 8: toggle every 8 cycles
          if (counter == 7) begin
            counter <= 3'd0;
            clk_out <= ~clk_out;
          end
          else begin
            counter <= counter + 1;
          end
        end
        default: begin // Out-of-range sel: hold clk_out at 0
          clk_out  <= 1'b0;
          counter  <= 3'd0;
        end
      endcase
    end
  end

endmodule