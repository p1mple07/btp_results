module complex_multiplier (
    input  logic clk,
    input  logic arst_n,
    input  logic [15:0] a_real,
    input  logic [15:0] a_imag,
    input  logic [15:0] b_real,
    input  logic [15:0] b_imag,
    output logic [31:0] result_real,
    output logic [31:0] result_imag
);

    // Compute the real and imaginary parts of the product in combinational logic.
    logic [31:0] real_temp;
    logic [31:0] imag_temp;

    assign real_temp = (a_real * b_real) - (a_imag * b_imag);
    assign imag_temp = (a_real * b_imag) + (a_imag * b_real);

    // Pipeline stage: register the computed result for one cycle latency.
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            result_real <= 32'd0;
            result_imag <= 32'd0;
        end else begin
            result_real <= real_temp;
            result_imag <= imag_temp;
        end
    end

endmodule