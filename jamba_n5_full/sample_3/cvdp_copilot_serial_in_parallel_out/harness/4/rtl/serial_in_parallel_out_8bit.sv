module serial_in_parallel_out_8bit(
    input wire clk,
    input wire serial_in,
    output reg [7:0] parallel_out
);

initial begin
    parallel_out = 8'b00000000;
end

always @(posedge clk) begin
    if (rising_edge(clk)) begin
        parallel_out[0] <= serial_in;
        for (int i = 1; i < 8; i++)
            parallel_out[i] <= parallel_out[i-1];
    end
end

endmodule
