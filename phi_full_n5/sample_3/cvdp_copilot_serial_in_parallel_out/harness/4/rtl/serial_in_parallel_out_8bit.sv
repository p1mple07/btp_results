module serial_in_parallel_out_8bit(
    input clock,
    input serial_in,
    output reg [7:0] parallel_out
);

    // State variable to keep track of the shift register
    reg [7:0] shift_reg;

    // Synchronous process triggered on the positive edge of the clock
    always @(posedge clock) begin
        // Shift the register to the left
        shift_reg <= {shift_reg[6:0], serial_in};
        // Update the parallel output with the new contents of the shift register
        parallel_out <= shift_reg;
    end

    // Initialize the shift register to all 'x' (unknown) on reset
    initial begin
        shift_reg = 8'bx;
    end

endmodule
