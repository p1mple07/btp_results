module restoring_division #(parameter WIDTH = 6)
(
    input wire clk,
    input wire rst_n,
    input wire start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output reg valid
);

    // Internal signals
    reg [WIDTH-1:0] int_remainder = 0;
    reg [WIDTH-1:0] int_quotient = 0;
    reg [WIDTH-1:0] shifted_remainder;

    // State
    reg [2:0] state = 3'b000;

    // Main Process
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            int_remainder <= 0;
            int_quotient <= 0;
            valid <= 0;
        end else if (start) begin
            state <= 3'b001;
            valid <= 0;
        end else if (state == 3'b001) begin
            shifted_remainder <= int_remainder << 1;
            shifted_remainder(WIDTH-1) <= dividend(WIDTH-1);
            if (divisor < 0) begin
                int_quotient <= 0;
                int_remainder <= 0;
            end else if (shifted_remainder >= divisor) begin
                int_quotient <= int_quotient | {1'b1, int_remainder(WIDTH-1)};
                int_remainder <= shifted_remainder - divisor;
                valid <= 1;
            end else begin
                int_quotient <= int_quotient | {1'b0, int_remainder(WIDTH-1)};
                int_remainder <= int_remainder << 1;
            end
            state <= state + 1;
        end
    end

    // Outputs
    assign quotient = int_quotient;
    assign remainder = int_remainder;
    assign valid = valid;

endmodule
