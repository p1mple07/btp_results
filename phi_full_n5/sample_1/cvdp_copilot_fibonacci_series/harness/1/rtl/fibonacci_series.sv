
module fibonacci_series (
    input clk,
    input rst,
    output reg [31:0] fib_out,
    output reg overflow_flag
);

    reg [31:0] RegA = 0;
    reg [31:0] RegB = 1;
    reg [31:0] next_fib;
    reg overflow_detected = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegA <= 0;
            RegB <= 1;
            fib_out <= 0;
            overflow_flag <= 0;
            overflow_detected <= 0;
        end else begin
            next_fib <= RegA + RegB;
            if (next_fib[31] == 1) begin
                overflow_detected <= 1;
                fib_out <= RegB;
                overflow_flag <= 1;
            end else begin
                RegA <= RegB;
                RegB <= next_fib;
                fib_out <= RegB;
            end
        end
    end
endmodule
