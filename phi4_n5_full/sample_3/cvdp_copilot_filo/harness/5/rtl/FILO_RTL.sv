module FILO_RTL #(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH  = 16
)(
    input  logic clk,
    input  logic reset,
    input  logic push,
    input  logic pop,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

    // Calculate the width needed for the stack pointer
    localparam integer LOG_DEPTH = $clog2(FILO_DEPTH);

    // Memory to store FILO data
    logic [DATA_WIDTH-1:0] mem [0:FILO_DEPTH-1];

    // Stack pointer: number of elements currently stored in the FILO
    logic [LOG_DEPTH-1:0] top;

    // Sequential process: operations occur on rising edge of clk or asynchronous reset
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            top       <= '0;
            full      <= 1'b0;
            empty     <= 1'b1;
            data_out  <= '0;
        end
        else begin
            // Temporary variable for pointer update
            integer new_top;
            new_top = top;  // Default: no change

            // Check for feedthrough scenario:
            // If the FILO is empty (top==0) and both push and pop are asserted,
            // pass data_in directly to data_out without storing it.
            if (top == 0 && push && pop) begin
                data_out <= data_in;
                // Memory and pointer remain unchanged.
            end
            // Push operation: valid only if the buffer is not full.
            else if (push && !full) begin
                mem[top] <= data_in;  // Store data_in at the current top position
                new_top  = top + 1;   // Increment pointer after push

                // If pop is also asserted, perform pop immediately.
                if (pop) begin
                    new_top  = new_top - 1;  // Decrement pointer due to pop
                    data_out <= mem[new_top]; // Output the pushed data
                end
                else begin
                    // No pop: data_out remains unchanged.
                    data_out <= data_out;
                end
            end
            // Pop operation: valid only if the buffer is not empty.
            else if (pop && !empty) begin
                new_top  = top - 1;   // Decrement pointer due to pop
                data_out <= mem[new_top]; // Output the popped data
            end
            // No valid operation: leave pointer and data_out unchanged.
            else begin
                data_out <= data_out;
            end

            // Update the stack pointer.
            top <= new_top;

            // Update status signals based on the pointer.
            full  <= (top == FILO_DEPTH);
            empty <= (top == 0);
        end
    end

endmodule