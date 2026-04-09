module complex_multiplier (
    input clk,
    input arst_n,
    input [15:0] a_real,
    input [15:0] a_imag,
    input [15:0] b_real,
    input [15:0] b_imag,
    output [31:0] result_real,
    output [31:0] result_imag
);

    reg [31:0] real_result, imag_result;

    // State machine for asynchronous active-low reset
    always @(posedge clk or posedge arst_n) begin
        if (arst_n == 1'b0) begin
            real_result <= 0;
            imag_result <= 0;
        end else if (arst_n == 1'b1) begin
            real_result <= {a_real[15:0], a_real[0]};
            imag_result <= {a_imag[15:0], a_imag[0]};
        end
    end

    // Compute the real and imaginary parts
    always @(posedge clk) begin
        real_result = (a_real * b_real) - (a_imag * b_imag);
        imag_result = (a_real * b_imag) + (a_imag * b_real);
    end

    // Output the results
    assign result_real = real_result;
    assign result_imag = imag_result;

endmodule
