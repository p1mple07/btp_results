module restoring_division #(parameter WIDTH = 6) (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [WIDTH-1:0] dividend,
    input wire [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output reg valid
);

    // Internal registers
    reg [WIDTH-1:0] int_dividend;
    reg [WIDTH-1:0] int_divisor;
    reg [WIDTH-1:0] int_remainder;
    reg [WIDTH-1:0] int_quotient;

    // Internal signals
    reg [WIDTH-1:0] shift_reg;

    // Processor
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int_dividend <= 0;
            int_divisor <= 0;
            int_remainder <= 0;
            int_quotient <= 0;
            valid <= 0;
        end else if (start) begin
            int_dividend <= dividend;
            int_divisor <= divisor;
            valid <= 1;
        end else if (valid) begin
            if (WIDTH == 1'b1 || WIDTH == 2'b10) begin
                if (int_remainder[WIDTH-1] == 0) begin
                    shift_reg <= int_remainder << 1;
                    shift_reg(WIDTH-1) <= int_dividend[WIDTH-1];
                    int_quotient(WIDTH-1) <= 1'b1;
                    int_remainder <= shift_reg;
                end else begin
                    shift_reg <= int_remainder << 1;
                    int_remainder <= shift_reg;
                    int_quotient(WIDTH-1) <= 1'b0;
                end
            end else begin
                shift_reg <= int_remainder << 1;
                shift_reg(WIDTH-1) <= int_dividend[WIDTH-1];
                if (int_remainder < int_divisor) begin
                    int_quotient(WIDTH-1) <= 1'b0;
                    int_remainder <= int_remainder << 1;
                end else begin
                    int_quotient(WIDTH-1) <= 1'b1;
                    int_remainder <= int_remainder - int_divisor;
                end
            end
        end
    end

    // Outputs
    assign quotient = int_quotient;
    assign remainder = int_remainder;

endmodule
