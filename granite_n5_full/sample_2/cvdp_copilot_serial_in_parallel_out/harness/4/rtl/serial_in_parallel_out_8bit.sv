module serial_in_parallel_out_8bit (
    input wire clk,
    input wire serial_in,
    output reg [7:0] parallel_out
);

always @(posedge clk) begin
    if (!parallel_out[7]) begin
        parallel_out <= {parallel_out[6:0], serial_in};
    end else begin
        parallel_out <= {parallel_out[6:0], parallel_out[5]};
    end
end

endmodule