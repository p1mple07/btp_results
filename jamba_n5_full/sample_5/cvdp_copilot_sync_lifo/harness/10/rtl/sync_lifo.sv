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

    // Counters and state variables
    reg [DEPTH-1:0] ptr;
    reg [DEPTH-1:0] lifo_counter;
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];
    reg [DATA_WIDTH-1:0] temp_data_out;
    integer i;

    // Error and validity signals
    output error;
    output valid;

    // Assignment for error: true when write to full or read from empty
    assign error = (write_en && full) || (read_en && empty);
    // Assignment for validity: data_out is valid only if no error occurred
    assign valid = (read_en && !empty) ? 1'b1 : 1'b0;

    // Write operation logic
    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};
            life_counter <= 0;
            empty = 1'b1;
            full = 1'b0;
        end else if (write_en && !full) begin
            memory[ptr] <= data_in;
            ptr <= ptr + 1;
        end else if (write_en && full) begin
            // Overflow detected: raise error
            error <= 1'b1;
        end
    end

    // Read operation logic
    always @(posedge clock) begin
        if (read_en && empty) begin
            // Underflow: raise error
            error <= 1'b1;
            valid <= 1'b0;
        end else if (read_en && not empty) begin
            temp_data_out <= memory[ptr - 1'b1];
            ptr <= ptr - 1;
        end
    end

    // Memory read and assignment
    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};
            life_counter <= 0;
            empty = 1'b1;
            full = 1'b0;
        end else if (read_en && !empty) begin
            temp_data_out <= memory[ptr - 1'b1];
            ptr <= ptr - 1;
        end
    end

    // Output data assignment
    assign data_out = temp_data_out;

endmodule
