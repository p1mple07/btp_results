module sync_lifo #(
    parameter DATA_WIDTH = 8,  // Width of the data
    parameter ADDR_WIDTH = 3   // Number of bits for the address (determines the depth)
)(
    input wire clock,                         // System clock
    input wire reset,                         // Synchronous reset
    input wire write_en,                      // Write enable
    input wire read_en,                       // Read enable
    input wire [DATA_WIDTH-1:0] data_in,      // Data input to be written into LIFO
    output wire error,                        // Error flag indicating invalid operation
    output wire valid,                        // Valid flag indicating valid data output
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
    assign error = ((lifo_counter == 0) && write_en) || ((lifo_counter == DEPTH) && read_en);  // Set error flag if both conditions are true
    assign valid = (lifo_counter > 0) && read_en;                                                 // Set valid flag if counter is greater than zero and read_en is high
    assign data_out = memory[ptr - 1'b1];                                                             // Assign data from memory at (pointer - 1)

    // Counter logic to track the number of elements in LIFO
    always @(posedge clock) begin
        if (reset) begin
            lifo_counter <= 0;                                                                          // Reset the counter when reset signal is active
        end else if (!full && write_en) begin
            lifo_counter <= lifo_counter + 1;                                                           // Increment counter on write if LIFO is not full
        end else if (!empty && read_en) begin
            lifo_counter <= lifo_counter - 1;                                                           // Decrement counter on read if LIFO is not empty
        end
    end

    // Memory write logic: writes data into the LIFO
    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};                                                              // Reset pointer to zero on reset
        end else if (write_en &&!full) begin
            memory[ptr] <= data_in;                                                                      // Write input data into memory at current pointer
            ptr <= ptr + 1;                                                                              // Increment pointer to next memory location
        end
    end

endmodule