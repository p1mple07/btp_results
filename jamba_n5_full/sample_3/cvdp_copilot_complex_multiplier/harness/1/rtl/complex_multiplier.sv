module complex_multiplier #(
    parameter WIDTH = 32
)(
    input wire clk,
    input wire arst_n,
    input wire a_real, a_imag,
    input wire b_real, b_imag,
    output reg [WIDTH-1:0] result_real,
    output reg [WIDTH-1:0] result_imag
);

    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            result_real <= 0;
            result_imag <= 0;
        end else begin
            // Compute real part: (a*c) - (b*d)
            result_real = a_real * b_real - a_imag * b_imag;
            // Compute imag part: (a*d) + (b*c)
            result_imag = a_real * b_imag + a_imag * b_real;
        end
    end

endmodule
