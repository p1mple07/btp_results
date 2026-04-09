Module declaration
module async_filo (
    // Inputs
    input clock [DATA_WIDTH-1:0] w_data,
    input clock [DATA_WIDTH-1:0] r_data,
    input clock w_clk,
    input clock r_clk,
    input high [1] w_rst,
    input high [1] r_rst,
    // Outputs
    output high [1] w_full,
    output high [1] r_empty
);

// Module parameters
parameter DATA_WIDTH = 8;
parameter DEPTH = 8;

// Module internals
reg [DEPTH][DATA_WIDTH] mem;
reg [DATA_WIDTH-1:0] w_ptr, r_ptr, w_count_bin, r_count_bin;
always @posedge w_clk begin
    // Convert binary write count to Gray code
    w_ptr = bin2gray(w_count_bin);
    w_count_bin = w_count_bin + 1;
end
always @posedge r_clk begin
    // Convert binary read count to Gray code
    r_ptr = bin2gray(r_count_bin);
    r_count_bin = r_count_bin + 1;
end

// Function to convert binary to Gray code
function bit [DATA_WIDTH-1:0] bin2gray(bit [DATA_WIDTH-1:0] bin_in);
    out = bin_in ^ (bin_in >> 1);
endfunction

// Function to convert Gray code to binary
function bit [DATA_WIDTH-1:0] gray2bin(bit [DATA_WIDTH-1:0] gray_in);
    out = gray_in ^ (gray_in >> 1);
endfunction

// Generate w_full and r_empty signals
wire w_full = (w_ptr >= r_ptr) ? 1 : 0;
wire r_empty = (r_ptr <= w_ptr) ? 1 : 0;

// Event-driven process for push and pop operations
process (*) begin
    while (!w_rst && !r_rst) begin
        // Simulate push operation
        if (!w_full) begin
            w_data is written to mem[w_ptr]
            w_ptr is incremented
        end

        // Simulate pop operation
        if (!r_empty) begin
            r_data is read from mem[r_ptr]
            r_ptr is decremented
        end
    end
endprocess

endmodule