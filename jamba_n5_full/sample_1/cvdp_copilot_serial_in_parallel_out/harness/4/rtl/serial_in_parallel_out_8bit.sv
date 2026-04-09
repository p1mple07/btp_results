module serial_in_parallel_out_8bit (
    input wire clock,
    input wire serial_in,
    output reg [7:0] parallel_out
);

reg [7:0] data;

always @(posedge clock) begin
    data <= {data[7:1], serial_in};
end

assign parallel_out = data;

endmodule
