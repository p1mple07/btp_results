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

// Internal registers for the shifted values and intermediate differences
reg [DATA_WIDTH-1:0] a_shift, b_shift;
reg signed [DATA_WIDTH-1:0] diff;

// Shift both inputs by the specified amount
always @(posedge clk or posedge rst_n) begin
  if (rst_n) begin
    a_shift <= 0; b_shift <= 0;
  end else begin
    a_shift = a <<< SHIFT_LEFT;
    b_shift = b <<< SHIFT_LEFT;
    diff = a_shift - b_shift;
  end
end

// Compute the output values based on the configuration
always @(*) begin
  if (enable) begin
    if (bypass) begin
      eq <= 1'b1;
      gt <= 1'b0; lt <= 1'b0;
    end else begin
      if (a_shift > b_shift) begin
        gt <= 1'b1;
      else if (a_shift < b_shift) begin
        gt <= 1'b0;
      end else begin
        gt <= 1'b1;
      end
      if (a_shift > b_shift) begin
        lt <= 1'b0;
      else
        lt <= 1'b1;
      end
      if (eq) begin
        eq <= 1'b1;
      end else begin
        eq <= 1'b0;
      end
    end
  end else begin
    // No tolerance or bypass, use direct comparison
    if (a_shift > b_shift) begin
      gt <= 1'b1;
    else if (a_shift < b_shift) begin
      gt <= 1'b0;
    end else begin
      gt <= 1'b1;
    end
    if (a_shift > b_shift) begin
      lt <= 1'b0;
    else
      lt <= 1'b1;
    end
    if (eq) begin
      eq <= 1'b1;
    end else begin
      eq <= 1'b0;
    end
  end
end

if (REGISTER_OUTPUT) begin
  #5;
  gt <= gt;
  lt <= lt;
  eq <= eq;
end else begin
  gt <= gt;
  lt <= lt;
  eq <= eq;
end

endmodule
