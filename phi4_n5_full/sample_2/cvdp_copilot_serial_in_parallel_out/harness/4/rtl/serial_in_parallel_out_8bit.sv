module serial_in_parallel_out_8bit(
    input  logic clock,
    input  logic serial_in,
    output logic [7:0] parallel_out
);

    // Initialize the register to an unknown state (all x).
    // In simulation this helps to illustrate that no data has been shifted in yet.
    initial begin
        parallel_out = 8'bx;
    end

    // On every rising edge of the clock, shift the register left by one bit.
    // The serial input is inserted into the LSB.
    always_ff @(posedge clock) begin
        parallel_out <= {parallel_out[6:0], serial_in};
    end

endmodule