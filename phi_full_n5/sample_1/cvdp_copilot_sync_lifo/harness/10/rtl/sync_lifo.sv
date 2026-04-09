
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
    , output wire error                       // Error indication for invalid operations
    , output reg valid                        // Validity indication for read operation
);

    // Calculate depth of the LIFO using the address width
    localparam DEPTH = (1 << ADDR_WIDTH);      // Depth = 2^ADDR_WIDTH

    // Registers for LIFO logic
    reg [DEPTH-1:0] ptr;                       // Pointer for write/read operations
    reg [DEPTH-1:0] lifo_counter;              // Counter to track the number of elements in the LIFO
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];   // Memory array to store LIFO data
    reg [DATA_WIDTH-1:0] temp_data_out;        // Temporary register for output data
    integer i;

    // Output assignments for empty, full, error, and valid flags
    assign empty = (lifo_counter == 0) ? 1'b1 : 1'b0;                  // LIFO is empty if counter is zero
    assign full  = (lifo_counter == DEPTH)? 1'b1 : 1'b0;               // LIFO is full if counter equals DEPTH
    assign valid = (read_en && !empty) ? 1'b1 : 1'b0;                    // Valid if read_en is high and LIFO is not empty
    assign error = (read_en && empty) | (write_en && full) ? 1'b1 : 1'b0; // Error if read_en is high and LIFO is empty or write_en is high and LIFO is full

    // Counter logic to track the number of elements in LIFO
    always @(posedge clock) begin
        if (reset) begin
            lifo_counter <= 0;                                          // Reset the counter when reset signal is active
        end else if (!full && write_en) begin
            lifo_counter <= lifo_counter + 1;                           // Increment counter on write if LIFO is not full
        end else if (!empty && read_en) begin
            lifo_counter <= lifo_counter - 1;                           // Decrement counter on read if LIFO is not empty
        end
    end

    // Memory write logic: writes data into the LIFO
    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};                                  // Reset pointer to zero on reset
        end else if (write_en && !full) begin
            memory[ptr] <= data_in;                                      // Write input data into memory at current pointer
            ptr <= ptr + 1;                                              // Increment pointer to next memory location
        end
    end

    // Memory read logic: reads data from the LIFO
    always @(posedge clock) begin
        if (reset) begin
            temp_data_out <= {DATA_WIDTH{1'b0}};                         // Clear output data on reset
            valid <= 1'b0;                                               // Set valid to low on reset
        end else if (read_en && !empty) begin
            temp_data_out <= memory[ptr - 1'b1];                         // Read data from memory at (pointer - 1)
            ptr <= ptr - 1;                                              // Decrement pointer after reading
            valid <= 1'b1;                                              // Set valid to high on successful read
        end
    end

    // Assign the output data
    assign data_out = temp_data_out;                                     // Assign temp data output to the actual output
endmodule
