
module fibonacci_series(
    input clk,
    input rst,
    output reg [31:0] fib_out,
    output reg overflow_flag
);

    reg [31:0] RegA = 32'd0;
    reg [31:0] RegB = 32'd1;
    reg [31:0] next_fib;
    reg overflow_detected = 0;

    always @(posedge clk) begin
        if (rst) begin
            RegA <= 32'd0;
            RegB <= 32'd1;
            fib_out <= 32'd0;
            overflow_flag <= 0;
            overflow_detected <= 0;
        end else begin
            next_fib <= RegA + RegB;
            
            if (next_fib[31] == 1) begin
                overflow_detected <= 1;
                overflow_flag <= 1;
                RegB <= RegA;
                fib_out <= RegB;
            end else begin
                RegA <= RegB;
                RegB <= next_fib;
                fib_out <= RegB;
                overflow_detected <= 0;
            end
        end
    end

endmodule
