module serial_in_parallel_out_8bit (
    input clock,
    input serial_in,
    output reg [7:0] parallel_out
);

    // Initial state
    initial parallel_out = 8'bx;

    // Shift register logic
    always @(posedge clock) begin
        if (serial_in) begin
            parallel_out <= {parallel_out[6:0], serial_in};
        end
        else begin
            parallel_out <= parallel_out << 1; // Shift left and discard MSB
        end
    end

endmodule
