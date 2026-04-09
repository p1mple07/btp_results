module serial_in_parallel_out_8bit(
    input clock,
    input serial_in,
    output reg [7:0] parallel_out
);

    // State register
    reg [7:0] state;

    // Clock edge detection
    always @(posedge clock) begin
        if (serial_in) begin
            // Shift in the new bit
            state <= state << 1;
            // Insert the new bit at the LSB
            state[0] <= serial_in;
        end
        // Output the parallel data
        parallel_out <= state;
    end

    // Initialization
    initial begin
        state <= 8'b00000000; // Set the initial state to all x's
    end

endmodule
