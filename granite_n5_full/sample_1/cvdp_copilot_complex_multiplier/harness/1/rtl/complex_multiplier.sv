module complex_multiplier (
  input clk, // 1 bit input
  input arst_n, // 1 bit input
  input [15:0] a_real, // 16 bit input
  input [15:0] a_imag, // 16 bit input
  input [15:0] b_real, // 16 bit input
  input [15:0] b_imag, // 16 bit input
  output reg [31:0] result_real, // 32 bit output
  output reg [31:0] result_imag // 32 bit output
);

  always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      result_real <= 0;
      result_imag <= 0;
    end else begin
      result_real <= a_real * b_real - a_imag * b_imag;
      result_imag <= a_real * b_imag + a_imag * b_real;
    end
  end

endmodule