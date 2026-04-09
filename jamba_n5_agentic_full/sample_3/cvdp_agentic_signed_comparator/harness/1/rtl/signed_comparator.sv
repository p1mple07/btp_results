`timescale 1ns/1ps

module signed_comparator #(
  parameter integer DATA_WIDTH = 16,
  parameter integer REGISTER_OUTPUT = 0,
  parameter integer ENABLE_TOLERANCE = 0,
  parameter integer TOLERANCE = 0,
  parameter integer SHIFT_LEFT = 0
)(
  input  wire clk,
  input  wire rst_n,
  input  wire enable,
  input  wire bypass,
  input  wire signed [DATA_WIDTH-1:0] a,
  input  wire signed [DATA_WIDTH-1:0] b,
  output reg gt,
  output reg lt,
  output reg eq
);

// Local variables
reg signed [DATA_WIDTH-1:0] a_shift, b_shift;
reg signed [DATA_WIDTH:0] diff_abs;
reg [DATA_WIDTH:0] temp;

always @(posedge clk or posedge rst_n) begin
  if (rst_n) begin
    gt <= 0; lt <= 0; eq <= 0;
    a_shift <= 0; b_shift <= 0; diff_abs <= 0;
  end else begin
    a_shift = a <<< SHIFT_LEFT;
    b_shift = b <<< SHIFT_LEFT;
    diff_abs = abs(a_shift - b_shift);
  end
end

always @(posedge clk) begin
  if (enable && !bypass) begin
    if (enable && (enable_tolerance && (abs(diff_abs) <= TOLERANCE))) begin
      eq <= 1;
      gt <= 0; lt <= 0;
    end else begin
      if (a_shift > b_shift) begin
        gt <= 1; lt <= 0; eq <= 0;
      end else if (a_shift < b_shift) begin
        gt <= 0; lt <= 1; eq <= 0;
      end else begin
        gt <= 0; lt <= 0; eq <= 1;
      end
    end
  end
end

endmodule
