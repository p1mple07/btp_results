module serial_in_parallel_out_8bit(
    input  logic clock,
    input  logic serial_in,
    output logic [7:0] parallel_out
);

    // On every rising edge of the clock, shift the register left by 1 bit
    // and insert the serial_in bit into the LSB position.
    always_ff @(posedge clock) begin
        parallel_out <= {parallel_out[6:0], serial_in};
    end

endmodule