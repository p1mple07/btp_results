module complex_multiplier #(
    parameter WIDTH = 16
)(
    input         clk,
    input         arst_n,
    input [WIDTH-1:0] a_real, a_imag,
    input [WIDTH-1:0] b_real, b_imag,
    output reg [WIDTH*2-1:0] result_real,
    output reg [WIDTH*2-1:0] result_imag
);

    always @(clk or arst_n) begin
        if (arst_n) begin
            result_real <= 32'h0;
            result_imag <= 32'h0;
        end else begin
            reg temp_real;
            reg temp_imag;
            temp_real = a_real * b_real;
            temp_imag = a_imag * b_imag;
            result_real <= temp_real - temp_imag;
            result_imag <= a_real * b_imag + a_imag * b_real;
        end
    end

endmodule
