parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 3;

parameter DEPTH = 1 << ADDR_WIDTH;

// Data array to store the LIFO elements
reg [DATA_WIDTH-1:0] data_array[DEPTH-1];
// Pointer to track the current position in the data array
reg pointer;

// Output signals
output empty, full;
output [DATA_WIDTH-1:0] data_out;

always @posedge clock begin
    if (reset) begin
        // Reset all outputs and clear the data array
        empty = 1;
        full = 1;
        data_out = 0;
        pointer = 0;
    end else if (write_en) begin
        // Check if there is space in the LIFO
        if (pointer < DEPTH) begin
            // Write the new data to the top of the LIFO
            data_array[pointer] = data_in;
            pointer++;
        end
    end else if (read_en) begin
        // Check if there is data to read from the LIFO
        if (pointer > 0) begin
            // Read the top data and update the pointer
            data_out = data_array[pointer-1];
            pointer--;
        end
    end
end