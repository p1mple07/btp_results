module serial_in_parallel_out_8bit (
    input wire clk,
    input wire serial_in,
    output reg [7:0] parallel_out
);

    always @(posedge clk) begin
        if (serial_in) begin
            parallel_out <= serial_in << 1;
        end else begin
            parallel_out <= 8'b0;
        end
    end

endmodule
