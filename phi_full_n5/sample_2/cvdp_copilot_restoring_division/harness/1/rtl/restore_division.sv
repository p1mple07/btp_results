module restoring_division #(parameter WIDTH = 6) (
    input clk,
    input rst_n,
    input start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output valid
);

    // Internal signals
    reg [WIDTH-1:0] internal_dividend = 0;
    reg [WIDTH-1:0] internal_remainder = 0;
    reg [WIDTH-1:0] quotient_bit = 0;
    reg valid_bit = 0;

    // State machine
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            quotient <= 0;
            remainder <= 0;
            valid_bit <= 0;
        end else if (start) begin
            internal_dividend <= dividend;
            internal_remainder <= remainder;
            valid_bit <= 1;
        end else if (valid_bit) begin
            quotient_bit <= quotient_bit;
            internal_remainder <= {internal_remainder[WIDTH-1:0], internal_dividend[0]} - divisor;
            if (internal_remainder[WIDTH-1:0] == (divisor << WIDTH-1)) begin
                quotient_bit <= ~quotient_bit;
                internal_remainder <= internal_remainder[WIDTH-1:0];
            end
            quotient <= quotient_bit;
            remainder <= internal_remainder;
            valid_bit <= 0;
        end
    end

endmodule
