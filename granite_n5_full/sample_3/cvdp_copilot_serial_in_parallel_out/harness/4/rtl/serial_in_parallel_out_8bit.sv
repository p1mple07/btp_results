module serial_in_parallel_out_8bit(
    input wire clk, // Clock signal that triggers the shift operation on its positive edge.
    input wire serial_in, // Serial input bit to be shifted into the register.
    output reg [7:0] parallel_out // 8-bit parallel output representing the current state of the register.
);

always @(posedge clk) begin
    if (serial_in == 1'b1) begin
        parallel_out <= {parallel_out[6:0], serial_in};
    end
end

endmodule