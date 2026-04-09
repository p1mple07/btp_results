module serial_in_parallel_out_8bit(
    input clock,
    input serial_in,
    output reg [7:0] parallel_out
);

    // State register to hold the current state of the shift register
    reg [7:0] shift_reg;

    // Clock edge detection
    always @(posedge clock) begin
        if (serial_in) begin
            // Shift in the new bit at the LSB position
            shift_reg <= {serial_in, shift_reg[6:0]};
        end
        // Update parallel_out with the shifted value
        parallel_out <= shift_reg;
    end

    // Initial state assignment
    initial begin
        shift_reg = 8'bx; // Set initial state to unknown logic levels
    end

endmodule
