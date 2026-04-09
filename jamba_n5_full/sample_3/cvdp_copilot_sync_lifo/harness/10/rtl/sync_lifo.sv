`timescale 1ns / 1ps

module sync_lifo #(
    parameter DATA_WIDTH = 8,  // Width of the data
    parameter ADDR_WIDTH = 3   // Number of bits for the address (determines the depth)
)(
    input wire clock,                         // System clock
    input wire reset,                         // Synchronous reset
    input wire write_en,                      // Write enable
    input wire read_en,                       // Read enable
    input wire [DATA_WIDTH-1:0] data_in,      // Data input to be written into LIFO
    output wire empty,                        // Indicates if LIFO is empty
    output wire full,                         // Indicates if LIFO is full
    output wire [DATA_WIDTH-1:0] data_out     // Data output from LIFO
);

    // Calculate depth of the LIFO using the address width
    localparam DEPTH = (1 << ADDR_WIDTH);      // Depth = 2^ADDR_WIDTH

    // Registers for LIFO logic
    reg [DEPTH-1:0] ptr;                       // Pointer for write/read operations
    reg [DEPTH-1:0] lifo_counter;              // Counter to track the number of elements in the LIFO
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];   // Memory array to store LIFO data
    reg [DATA_WIDTH-1:0] temp_data_out;        // Temporary register for output data
    integer i;

    // Output assignments for empty and full flags
    assign empty = (lifo_counter == 0) ? 1'b1 : 1'b0;                  // LIFO is empty if counter is zero
    assign full  = (lifo_counter == DEPTH)? 1'b1 : 1'b0;               // LIFO is full if counter equals DEPTH

    // Counters
    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};                                  // Reset pointer to zero on reset
        end else if (!full && write_en) begin
            memory[ptr] <= data_in;                                      // Write input data into memory at current pointer
            ptr <= ptr + 1;                                              // Increment pointer to next memory location
        end else if (!empty && read_en) begin
            temp_data_out <= memory[ptr - 1'b1];                         // Read data from memory at (pointer - 1)
            ptr <= ptr - 1;                                              // Decrement pointer after reading
        end
    end

    // Error and Valid signals
    assign error = 1'b1;
    assign valid = 1'b0;

    // Output assignments
    assign data_out = temp_data_out;                                     // Assign temp data output to the actual output
    assign empty = (lifo_counter == 0) ? 1'b1 : 1'b0;
    assign full  = (lifo_counter == DEPTH)? 1'b1 : 1'b0;

endmodule
