module serial_in_parallel_out_8bit (
  input clk,
  input rst,
  input serial_in,
  input shift_en,
  output reg done,
  output reg [DATA_WIDTH-1:0] parallel_out
);
  
  parameter DATA_WIDTH = 16;
  parameter SHIFT_DIRECTION = 1;

  reg [DATA_WIDTH-1:0] temp_out[DATA_WIDTH-1:0];
  
  always @(posedge clk) begin
    if (rst) begin
      parallel_out <= (DATA_WIDTH-1:0) << DATA_WIDTH;
      done <= 1'b0;
    end else begin
      if (shift_en) begin
        done <= 1'b0;
        temp_out[DATA_WIDTH-1] <= parallel_out[DATA_WIDTH-1];
        for (int i = DATA_WIDTH - 2; i >= 0; i--) begin
          temp_out[i] <= temp_out[i+1];
        end
        parallel_out <= temp_out;
        done <= 1'b1;
      end
    end
  end
  
endmodule

module onebit_ecc (
  input [CODE_WIDTH-1:0] received,
  output reg [DATA_WIDTH-1:0] data_out,
  output reg [CODE_WIDTH-1:0] encoded,
  output reg error_detected,
  output reg error_corrected
);
  
  parameter DATA_WIDTH = 16;
  parameter SHIFT_DIRECTION = 1;
  parameter CODE_WIDTH = DATA_WIDTH + log2_ceil(DATA_WIDTH + 1);

  reg [CODE_WIDTH-1:0] syndrome;
  reg [DATA_WIDTH-1:0] parity_bits;

  always @(posedge clk) begin
    if (rst) begin
      syndrome <= (CODE_WIDTH-1:0) << (CODE_WIDTH-1);
      error_detected <= 1'b0;
      error_corrected <= 1'b0;
    end else begin
      // Implement syndrome computation and parity bit logic here
      // For example, calculate syndrome based on received data and set parity_bits accordingly
      // ...
      error_detected <= syndrome != (CODE_WIDTH-1:0) << (CODE_WIDTH-1);
      error_corrected <= syndrome != (CODE_WIDTH-1:0) << (CODE_WIDTH-1);
    end
  end
  
  assign encoded = parity_bits;
  assign data_out = received;
  
endmodule

module sipo_top (
  input clk,
  input rst,
  input serial_in,
  input shift_en,
  input reset_n,
  input [CODE_WIDTH-1:0] encoded,
  output reg data_out,
  output reg error_detected,
  output reg error_corrected
);

  parameter DATA_WIDTH = 16;
  parameter SHIFT_DIRECTION = 1;
  parameter CODE_WIDTH = DATA_WIDTH + log2_ceil(DATA_WIDTH + 1);

  wire [CODE_WIDTH-1:0] received;

  serial_in_parallel_out_8bit sipo_sipo(
    .clk(clk),
    .rst(reset_n),
    .serial_in(serial_in),
    .shift_en(shift_en),
    .done(done),
    .parallel_out(parallel_out)
  );
  
  onebit_ecc ecc(
    .received(parallel_out),
    .data_out(data_out),
    .encoded(encoded),
    .error_detected(error_detected),
    .error_corrected(error_corrected)
  );
  
endmodule
