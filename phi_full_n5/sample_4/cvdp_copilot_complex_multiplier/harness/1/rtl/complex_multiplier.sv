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

    // Internal signals
    reg [31:0] real_result;
    reg [31:0] imag_result;

    // State machine for one cycle latency
    always @(posedge clk or posedge arst_n) begin
        if (arst_n) begin
            real_result <= 0;
            imag_result <= 0;
        end else if (!(arst_n)) begin
            // Real part calculation
            real_result <= (a_real * b_real) - (a_imag * b_imag);
            // Imaginary part calculation
            imag_result <= (a_real * b_imag) + (a_imag * b_real);
            // Output the results on the next clock cycle
            if (~arst_n) begin
                result_real <= real_result;
                result_imag <= imag_result;
            end
        end
    end

endmodule
