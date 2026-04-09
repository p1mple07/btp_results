
module fibonacci_series (
    input clk,
    input rst,
    output reg [31:0] fib_out,
    output reg overflow_flag
);

    reg [31:0] RegA = 0;
    reg [31:0] RegB = 1;
    reg overflow_detected = 0;

    always @(posedge clk) begin
        if (rst) begin
            RegA <= 0;
            RegB <= 1;
            fib_out <= 0;
            overflow_detected <= 0;
            overflow_flag <= 0;
        end else begin
            if (overflow_detected) begin
                fib_out <= RegB;
                overflow_detected <= 0;
                overflow_flag <= 1;
            end else begin
                if (RegB > 32'h7FFFFFFF) begin
                    overflow_detected <= 1;
                    fib_out <= RegB;
                end else begin
                    RegA <= RegB;
                    RegB <= RegA + RegB;
                    fib_out <= RegB;
                end
            end
        end
    end

endmodule
