module restoring_division #(parameter WIDTH = 6) (
    input clk,
    input rst_n,
    input start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg remainder,
    output valid
);

    reg [WIDTH-1:0] temp_remainder;
    reg [WIDTH-1:0] temp_quotient;

    // Initialization
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            temp_remainder <= 0;
            temp_quotient <= 0;
            quotient <= 0;
            remainder <= 0;
            valid <= 0;
        end else if (start) begin
            temp_remainder <= dividend;
            temp_quotient <= 0;
            valid <= 1;
        end
    end

    // Shift and Subtract
    always @(posedge clk) begin
        if (valid) begin
            if (temp_remainder >= divisor) begin
                temp_remainder <= {temp_remainder[WIDTH-1:1], 1'b0};
                temp_quotient <= temp_quotient | (temp_remainder[WIDTH-1] & divisor[WIDTH-1] == 0);
                temp_remainder <= temp_remainder - divisor;
            end else begin
                temp_remainder <= 0;
                temp_quotient <= 0;
            end
        end
    end

    // Assign outputs
    assign quotient = temp_quotient;
    assign remainder = temp_remainder;
    assign valid = (WIDTH < 6) ? 1'b1 : 1'b0; // Assuming WIDTH >= 6 for correctness

endmodule
