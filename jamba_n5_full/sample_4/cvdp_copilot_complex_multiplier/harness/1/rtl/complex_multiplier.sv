module complex_multiplier (
    input wire clk,
    input wire arst_n,
    input wire a_real, a_imag,
    input wire b_real, b_imag,
    output reg result_real,
    output reg result_imag
);

    initial begin
        result_real = 0;
        result_imag = 0;
    end

    always @(clk or arst_n) begin
        if (arst_n) begin
            result_real = 0;
            result_imag = 0;
        end else begin
            result_real = a_real * b_real - a_imag * b_imag;
            result_imag = a_real * b_imag + a_imag * b_real;
        end
    end

endmodule
