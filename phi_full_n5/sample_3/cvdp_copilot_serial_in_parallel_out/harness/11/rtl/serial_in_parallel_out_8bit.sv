
module serial_in_parallel_out_8bit (
  input clk,
  input reset_n,
  input serial_in,
  input shift_en,
  output reg done,
  output reg [7:0] parallel_out
);
  
  parameter DATA_WIDTH = 16;
  parameter SHIFT_DIRECTION = 1;
  
  reg [DATA_WIDTH-1:0] temp_data [DATA_WIDTH-1:0];
  reg [DATA_WIDTH-1:0] temp_data_out [DATA_WIDTH-1:0];
  
  always @(posedge clk) begin
    if (reset_n) begin
      parallel_out <= '0;
      temp_data <= '0;
      temp_data_out <= '0;
    end else begin
      if (shift_en) begin
        if (SHIFT_DIRECTION == 1) begin
          temp_data <= parallel_out << 1;
          parallel_out <= temp_data[DATA_WIDTH-1:0];
        end else begin
          temp_data <= parallel_out >> 1;
          parallel_out <= temp_data[DATA_WIDTH-1:0];
        end
      end
    end
  end
  
  always @(posedge clk) begin
    if (shift_en) begin
      done <= 1;
      if (shift_en) begin
        temp_data_out <= temp_data;
      end else begin
        temp_data_out <= '0;
      end
    end else begin
      done <= 0;
      temp_data_out <= '0;
    end
  end
  
endmodule
