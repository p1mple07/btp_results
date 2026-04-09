module restoring_division(
    input wire clock,
    input wire rst,
    input wire start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output reg valid
);

    reg [WIDTH-1:0] remainder_reg;
    reg [WIDTH-1:0] quotient_reg;
    reg [WIDTH-1:0] dividend_reg;
    reg [WIDTH-1:0] divisor_reg;
    reg [WIDTH-1:0] temp_reg;

    if (rst) begin
        remainder_reg = 0;
        quotient_reg = 0;
        valid = 0;
        return;
    end

    always clock begin
        if (start && !valid) begin
            valid = 1;
            dividend_reg = dividend;
            divisor_reg = divisor;
        end

        if (valid) begin
            remainder_reg = (remainder_reg << 1) | (dividend_reg >> (WIDTH - 1));
            temp_reg = remainder_reg - divisor_reg;
            
            if (temp_reg >= 0) begin
                quotient_reg = (quotient_reg << 1) | 1;
                remainder_reg = temp_reg;
            else begin
                quotient_reg = quotient_reg << 1;
                remainder_reg = remainder_reg >> 1;
            end
        end

        if (valid && (valid after 1 clock cycle)) begin
            valid = 1;
        end
    end
endmodule