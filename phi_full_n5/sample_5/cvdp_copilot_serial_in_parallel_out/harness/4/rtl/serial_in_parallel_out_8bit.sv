module serial_in_parallel_out_8bit (
    input clk,
    input serial_in,
    output reg [7:0] parallel_out
);

    // State variable to hold the current parallel output
    reg [7:0] current_parallel_out;

    // Initial state with all bits set to 'x'
    initial begin
        current_parallel_out = 8'bx;
    end

    // Combinational logic to shift the register on each positive clock edge
    always @(posedge clk) begin
        if (~current_parallel_out[7]) begin
            // Shift the register by moving the current MSB to the LSB position
            current_parallel_out <= {current_parallel_out[6:0], serial_in};
        end
        // Update the parallel output with the current state
        parallel_out <= current_parallel_out;
    end

endmodule
