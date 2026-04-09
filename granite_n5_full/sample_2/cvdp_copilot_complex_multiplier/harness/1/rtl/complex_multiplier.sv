module complex_multiplier (
  input clk, 
  input arst_n, 
  input [15:0] a_real, 
  input [15:0] a_imag, 
  input [15:0] b_real, 
  input [15:0] b_imag,
  output reg [31:0] result_real, 
  output reg [31:0] result_imag
);

  reg [15:0] temp_real;
  reg [15:0] temp_imag;

  always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      temp_real <= 16'd0;
      temp_imag <= 16'd0;
    end else begin
      temp_real <= a_real * b_real - a_imag * b_imag;
      temp_imag <= a_real * b_imag + a_imag * b_real;
    end
  end

  assign result_real = temp_real;
  assign result_imag = temp_imag;

endmodule