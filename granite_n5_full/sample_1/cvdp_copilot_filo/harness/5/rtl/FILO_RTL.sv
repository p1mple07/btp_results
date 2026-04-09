module FILO_RTL(
    input clk, // Clock signal
    input rst, // Reset signal
    input push, // Push operation signal
    input pop, // Pop operation signal
    input [DATA_WIDTH-1:0] data_in, // Input data
    output logic [DATA_WIDTH-1:0] data_out, // Output data
    output logic full, // Full flag
    output logic empty // Empty flag
);

// Define local parameters
localparam DATA_WIDTH = 8; // Width of input data
localparam FIFO_DEPTH = 8; // Depth of the FIFO

// Define internal signals
reg [DATA_WIDTH-1:0] fifo[FIFO_DEPTH]; // FIFO storage array
reg [7:0] read_ptr; // Read pointer
reg [7:0] write_ptr; // Write pointer
reg [7:0] count; // Count of elements in the FIFO

// Implement reset behavior
always @(posedge clk or posedge rst) begin
    if (rst) begin
        read_ptr <= 0;
        write_ptr <= 0;
        count <= 0;
        for (int i=0; i<FIFO_DEPTH; i++) begin
            fifo[i] <= 8'b0000000; // Initialize FIFO with all zeros
        end
        full <= 0; // Set full flag to 0 initially
        empty <= 1; // Set empty flag to 1 initially
    end else begin
        // Update full and empty flags based on push and pop operations
        if (push && empty) begin
            full <= 1; // Set full flag to 1
        end else if (!push && pop) begin
            full <= 0; // Set full flag to 0
        end

        if (push &&!full) begin
            data_out <= fifo[read_ptr]; // Assign the value at read_ptr to data_out
        end else if (!push and pop) begin
            data_out <= fifo[write_ptr]; // Assign the value at write_ptr to data_out
        end
    end
endmodule