module serial_in_parallel_out_8bit(
    input  logic clock,
    input  logic serial_in,
    output logic [7:0] parallel_out
);

    // On every rising edge of the clock, shift the register left and insert serial_in at LSB.
    always_ff @(posedge clock) begin
        parallel_out <= (parallel_out << 1) | serial_in;
    end

endmodule