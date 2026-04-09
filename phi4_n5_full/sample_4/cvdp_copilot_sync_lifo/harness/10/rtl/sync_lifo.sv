module sync_lifo #(
    parameter DATA_WIDTH = 8,  // Width of the data
    parameter ADDR_WIDTH = 3   // Number of bits for the address (determines the depth)
)(
    input  wire          clock,       // System clock
    input  wire          reset,       // Synchronous reset
    input  wire          write_en,    // Write enable
    input  wire          read_en,     // Read enable
    input  wire [DATA_WIDTH-1:0] data_in, // Data input to be written into LIFO
    output wire          empty,       // Indicates if LIFO is empty
    output wire          full,        // Indicates if LIFO is full
    output wire [DATA_WIDTH-1:0] data_out, // Data output from LIFO
    output wire          error,       // High when an invalid operation occurs (overflow/underflow)
    output wire          valid        // High when data_out contains valid data after a successful read
);

    // Calculate depth of the LIFO using the address width
    localparam DEPTH = (1 << ADDR_WIDTH);  // Depth = 2^ADDR_WIDTH

    // Registers for LIFO logic
    reg [DEPTH-1:0] ptr;                       // Pointer for write/read operations
    reg [DEPTH-1:0] lifo_counter;              // Counter to track the number of elements in the LIFO
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];   // Memory array to store LIFO data
    reg [DATA_WIDTH-1:0] temp_data_out;        // Temporary register for output data
    reg error, valid;                          // New registers for error and valid signals

    // Output assignments for empty and full flags
    assign empty = (lifo_counter == 0) ? 1'b1 : 1'b0;                  // LIFO is empty if counter is zero
    assign full  = (lifo_counter == DEPTH) ? 1'b1 : 1'b0;               // LIFO is full if counter equals DEPTH

    // Counter logic to track the number of elements in LIFO
    always @(posedge clock) begin
        if (reset) begin
            lifo_counter <= 0;  // Reset the counter when reset signal is active
        end else begin
            // Handle error conditions: do not update counter if invalid operation
            if (write_en && full) begin
                // Overflow: write attempted on full LIFO; error will be asserted externally
            end else if (write_en && !full) begin
                lifo_counter <= lifo_counter + 1;  // Increment counter on valid write
            end else if (read_en && empty) begin
                // Underflow: read attempted on empty LIFO; error will be asserted externally
            end else if (read_en && !empty) begin
                lifo_counter <= lifo_counter - 1;  // Decrement counter on valid read
            end
        end
    end

    // Memory write logic: writes data into the LIFO
    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};  // Reset pointer to zero on reset
        end else begin
            if (write_en && !full) begin
                memory[ptr] <= data_in;  // Write input data into memory at current pointer
                ptr <= ptr + 1;          // Increment pointer to next memory location
            end
            // If write_en && full, do nothing (error will be asserted)
        end
    end

    // Memory read logic: reads data from the LIFO
    always @(posedge clock) begin
        if (reset) begin
            temp_data_out <= {DATA_WIDTH{1'b0}};  // Clear output data on reset
        end else begin
            if (read_en && !empty) begin
                temp_data_out <= memory[ptr - 1'b1];  // Read data from memory at (pointer - 1)
                ptr <= ptr - 1;                      // Decrement pointer after reading
            end
            // If read_en && empty, do nothing (error will be asserted)
        end
    end

    // Error and Valid logic: 
    // - If write_en is high and LIFO is full, assert error.
    // - If read_en is high and LIFO is empty, assert error and keep valid low.
    // - If read_en is high and LIFO is not empty, assert valid.
    always @(posedge clock) begin
        if (reset) begin
            error <= 1'b0;
            valid <= 1'b0;
        end else begin
            // Default: clear error and valid signals
            error <= 1'b0;
            valid <= 1'b0;
            if (write_en && full) begin
                error <= 1'b1;
            end
            if (read_en && empty) begin
                error <= 1'b1;
            end
            if (read_en && !empty) begin
                valid <= 1'b1;
            end
        end
    end

    // Assign the output data
    assign data_out = temp_data_out;  // Assign temp data output to the actual output

endmodule