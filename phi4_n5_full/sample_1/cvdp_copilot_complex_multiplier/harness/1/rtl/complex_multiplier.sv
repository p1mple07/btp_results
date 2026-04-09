module complex_multiplier(
    input  logic         clk,
    input  logic         arst_n,
    input  logic [15:0]  a_real,
    input  logic [15:0]  a_imag,
    input  logic [15:0]  b_real,
    input  logic [15:0]  b_imag,
    output logic [31:0]  result_real,
    output logic [31:0]  result_imag
);

  // The design computes the complex multiplication:
  //   (a_real + j*a_imag) * (b_real + j*b_imag) =
  //   (a_real*b_real - a_imag*b_imag) + j*(a_real*b_imag + a_imag*b_real)
  // The computed result is registered for one cycle latency.
  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      result_real <= 32'd0;
      result_imag <= 32'd0;
    end else begin
      result_real <= (a_real * b_real) - (a_imag * b_imag);
      result_imag <= (a_real * b_imag) + (a_imag * b_real);
    end
  end

endmodule