
module fibonacci_series (
    input clk,
    input rst,
    output reg [31:0] fib_out,
    output reg overflow_flag
);

    reg [31:0] RegA = 32'd0;
    reg [31:0] RegB = 32'd1;
    reg overflow_detected = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegA <= 32'd0;
            RegB <= 32'd1;
            fib_out <= 32'd0;
            overflow_flag <= 0;
        end else begin
            if (overflow_detected) begin
                fib_out <= RegB;
                overflow_flag <= 1;
                RegA <= 32'd0;
                RegB <= 32'd1;
            end else begin
                next_fib <= RegA + RegB;
                if (next_fib[32] == 1'b1) begin
                    overflow_detected <= 1'b1;
                end else begin
                    overflow_detected <= 1'b0;
                end
                fib_out <= RegB;
                RegA <= next_fib[31:0];
                RegB <= next_fib[32:31];
            end
        end
    end
endmodule
