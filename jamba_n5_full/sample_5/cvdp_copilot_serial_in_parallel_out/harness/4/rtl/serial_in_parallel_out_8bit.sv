module serial_in_parallel_out_8bit(
    input wire clock,
    input wire serial_in,
    output reg [7:0] parallel_out
);

    initial begin
        parallel_out = 8'b00000000;
    end

    always @(posedge clock) begin
        if (serial_in) begin
            parallel_out = {0, serial_in, parallel_out[6:1]};
        end else begin
            parallel_out = {0, 0, 0}; // or keep same? but initial is 0, so it's fine.
        end
    end

endmodule
