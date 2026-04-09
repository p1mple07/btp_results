Module parameters
$parameter CACHE_SIZE   = 256; // Number of cache lines
$parameter DATA_WIDTH   = 16;  // Width of data
$parameter TAG_WIDTH    = 5;   // Width of the tag
$parameter OFFSET_WIDTH = 3;   // Width of the offset

// Calculate index width
$local param INDEX_WIDTH = $clog2(CACHE_SIZE);

// Module ports
input  clk;
input  rst;
input  [INDEX_WIDTH-1:0] index;
input  [OFFSET_WIDTH-1:0] offset;
input  [TAG_WIDTH-1:0]   tag_in;
input  [DATA_WIDTH-1:0]  data_in;
input  valid_in;
output hit;
output dirty;
output [TAG_WIDTH-1:0] tag_out;
output [DATA_WIDTH-1:0] data_out;
output valid;
output error;

// Internal state variables
reg [INDEX_WIDTH-1:0] stored_index;
reg [OFFSET_WIDTH-1:0] stored_offset;
reg [TAG_WIDTH-1:0]    stored_tag;
reg [DATA_WIDTH-1:0]   stored_data;

// Module behavior description
always_comb begin
    // Parameterized compare
    case (comp)
        1: // Compare mode (tag matching allowed)
            if (write) begin
                // Memory read/writes
                if (valid_in) begin
                    // Access memory
                    tag_out = tag_in;
                    data_out = data_in;
                    // Update validity and dirty status
                    if (write) begin
                        valid = valid_in;
                        dirty = 1;
                    end else begin
                        valid = 0;
                        dirty = 0;
                    end
                end else begin
                    // Invalidate entire cache line
                    valid = 0;
                    dirty = 1;
                end
            end else begin
                // No memory access
                valid = 0;
                dirty = 0;
            end
        0: // Non-compare mode (exact match required)
            if (write) begin
                // Overwrite data
                tag_out = tag_in;
                data_out = data_in;
                dirty = 1;
            end else begin
                // Read data
                tag_out = stored_tag;
                data_out = stored_data;
            end
            valid = valid_in;
        end // end case
    end // end always_comb

    // Handle index overflow
    if (offset[0] == 1'b1) begin
        // Invalid access due to unaligned address
        error = 1;
    end
endmodule