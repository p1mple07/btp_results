module direct_map_cache #(
    parameter CACHE_SIZE = 256,
    parameter DATA_WIDTH = 16,
    parameter TAG_WIDTH = 5,
    parameter OFFSET_WIDTH = 3
)(
    input clk,
    input rst,
    input enable,
    input [INDEX_WIDTH-1:0] index,
    input [OFFSET_WIDTH-1:0] offset,
    input comp,
    input write,
    input [TAG_WIDTH-1:0] tag_in,
    input [DATA_WIDTH-1:0] data_in,
    input valid_in,
    output reg hit,
    output reg dirty,
    output reg [TAG_WIDTH-1:0] tag_out,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg valid,
    output reg error
);

// Internal signals
reg [TAG_WIDTH-1:0] stored_tag;
reg [DATA_WIDTH-1:0] stored_data;
reg [OFFSET_WIDTH-1:0] stored_offset;
reg [INDEX_WIDTH-1:0] stored_index;
reg [DATA_WIDTH-1:0] data_mem[CACHE_SIZE];
reg [TAG_WIDTH-1:0] tag_mem[CACHE_SIZE];

always @(posedge clk) begin
    // Reset on rising edge
    if (rst) begin
        clk <= 0;
        enable <= 0;
        comp <= 0;
        write <= 0;
        index <= 0;
        offset <= 0;
        tag_in <= 0;
        data_in <= 0;
        valid_in <= 0;
        hit <= 0;
        dirty <= 0;
        tag_out <= 0;
        data_out <= 0;
        valid <= 0;
        error <= 0;
    end
    else begin
        // Check offset for error
        if (offset[0] == 1'b1) begin
            error <= 1;
            hit <= 0;
            dirty <= 0;
            valid <= 0;
            data_out <= 0;
            tag_out <= 0;
            return;
        end

        // Find the block
        stored_index = index;
        stored_tag = tag_in;
        stored_offset = offset;
        stored_data = data_in;

        // Validate
        hit = (comp && valid) ? 1 : 0;
        valid = valid_in;
        data_out = data_in;
        tag_out = tag_in;
        dirty = (write && (valid && !dirty)) ? 1 : 0;

        // Check write and read conditions
        if (write && comp) begin
            // Write case
            // If tag matches, update data
            if (tag_in == stored_tag) begin
                data_mem[stored_index] <= data_in;
            end
            // Set dirty if write
            dirty = 1;
        end else if (read) begin
            // Read case
            // If tag matches, return data
            if (tag_in == stored_tag) begin
                hit = 1;
                data_out = stored_data;
                valid = 1;
                dirty = 0;
            end else begin
                // Miss
                hit = 0;
                valid = 0;
                data_out <= 0;
            end
        end
    end
endmodule
