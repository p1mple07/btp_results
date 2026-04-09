module complex_multiplier(
    input clk,
    input arst_n,
    input [15:0] a_real,
    input [15:0] a_imag,
    input [15:0] b_real,
    input [15:0] b_imag,
    output reg [31:0] result_real,
    output reg [31:0] result_imag
);

    reg [31:0] temp_real, temp_imag;

    // State machine for one cycle latency
    always @(posedge clk or posedge arst_n) begin
        if (arst_n) begin
            temp_real <= 0;
            temp_imag <= 0;
        end else begin
            // Real Part Calculation
            temp_real <= (a_real * b_real) - (a_imag * b_imag);
            // Imaginary Part Calculation
            temp_imag <= (a_real * b_imag) + (a_imag * b_real);
        end
    end

    // Assign outputs
    assign result_real = temp_real;
    assign result_imag = temp_imag;

    // Asynchronous Active Low Reset
    always @(posedge clk or posedge arst_n) begin
        if (arst_n) begin
            result_real <= 0;
            result_imag <= 0;
        end
    end

endmodule
