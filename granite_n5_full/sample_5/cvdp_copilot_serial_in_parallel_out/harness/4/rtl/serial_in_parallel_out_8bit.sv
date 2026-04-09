module serial_in_parallel_out_8bit(
    input wire clock,
    input wire serial_in,
    output reg [7:0] parallel_out
);

always @(posedge clock) begin
    if (!parallel_out) begin
        parallel_out <= {8{serial_in}};
    end else begin
        parallel_out <= parallel_out >> 1;
        parallel_out[0] <= serial_in;
    end
end

endmodule