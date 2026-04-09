module fibonacci_series (
    input wire clk,
    input wire rst,
    output reg [31:0] fib_out,
    output reg overflow_flag
);

reg [31:0] RegA;
reg [31:0] RegB;
reg [31:0] next_fib;
reg overflow_detected;

always @ (posedge clk) begin
    if (rst) begin
        RegA <= 32'h0;
        RegB <= 32'h1;
        fib_out <= 32'h0;
        overflow_flag <= 1'b0;
    end else begin
        next_fib <= RegA + RegB;
        
        if (next_fib > 32'hFFFF_FFFF) begin
            overflow_detected <= 1'b1;
        end
        
        if (overflow_detected) begin
            overflow_flag <= 1'b1;
            RegA <= 32'h0;
            RegB <= 32'h1;
        end else begin
            RegA <= RegB;
            RegB <= next_fib;
            fib_out <= RegB;
        end
    end
end

endmodule