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
    output wire [DATA_WIDTH-1:0] data_out,    // Data output from LIFO
    output wire error,                        // Error signal: high when an invalid operation occurs
    output wire valid                         // Valid signal: high when data_out contains valid data after a successful read
);

    // Calculate depth of the LIFO using the address width
    localparam DEPTH = (1 << ADDR_WIDTH);      // Depth = 2^ADDR_WIDTH

    // Registers for LIFO logic
    reg [DEPTH-1:0] ptr;                       // Pointer for write/read operations
    reg [DEPTH-1:0] lifo_counter;              // Counter to track the number of elements in the LIFO
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];   // Memory array to store LIFO data
    reg [DATA_WIDTH-1:0] temp_data_out;        // Temporary register for output data
    integer i;
    reg error_reg;                             // Internal register for error signal
    reg valid_reg;                             // Internal register for valid signal

    // Combinational outputs
    assign empty  = (lifo_counter == 0) ? 1'b1 : 1'b0;
    assign full   = (lifo_counter == DEPTH) ? 1'b1 : 1'b0;
    assign data_out = temp_data_out;
    assign error   = error_reg;
    assign valid   = valid_reg;

    // Combined sequential logic for counter, pointer, memory, error and valid signals.
    // On reset, all registers are cleared.
    // For write operations: if write_en is high and LIFO is full, error is asserted and no update occurs.
    // For read operations: if read_en is high and LIFO is empty, error is asserted and valid remains 0.
    // On successful read (read_en && !empty), data_out is updated and valid is set high.
    // In this implementation, if both write and read are active, the write operation takes priority.
    always @(posedge clock) begin
        if (reset) begin
            lifo_counter <= 0;
            ptr          <= 0;
            temp_data_out<= {DATA_WIDTH{1'b0}};
            error_reg    <= 0;
            valid_reg    <= 0;
        end else begin
            // Check for error conditions first
            if (write_en && full) begin
                error_reg <= 1;
            end else if (read_en && empty) begin
                error_reg <= 1;
                valid_reg <= 0;
            end else begin
                error_reg <= 0;
                // If write is enabled and LIFO is not full, perform write operation
                if (write_en && !full) begin
                    memory[ptr]      <= data_in;
                    lifo_counter     <= lifo_counter + 1;
                    ptr              <= ptr + 1;
                end
                // Else if read is enabled and LIFO is not empty, perform read operation
                else if (read_en && !empty) begin
                    temp_data_out   <= memory[ptr - 1];
                    lifo_counter    <= lifo_counter - 1;
                    ptr             <= ptr - 1;
                    valid_reg       <= 1;
                end else begin
                    valid_reg <= 0;
                end
            end
        end
    end

endmodule