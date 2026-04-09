module serial_in_parallel_out_8bit(
    input  logic clock,
    input  logic serial_in,
    output logic [7:0] parallel_out
);

    // On every positive edge of the clock, shift the register left by one bit.
    // The MSB is dropped and the serial_in bit is inserted at the LSB.
    always_ff @(posedge clock) begin
        parallel_out <= {parallel_out[6:0], serial_in};
    end

endmodule