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
    output [TAG_WIDTH-1:0] tag_out,
    output [DATA_WIDTH-1:0] data_out,
    output valid,
    output error
);

// Internal signals
reg [TAG_WIDTH-1:0] stored_tag;
reg [DATA_WIDTH-1:0] stored_data;
reg [OFFSET_WIDTH-1:0] stored_offset;
reg [INDEX_WIDTH-1:0] stored_index;

// Counters
localparam INDEX_SHIFT = OFFSET_WIDTH;
localparam OFFSET_SHIFT = INDEX_WIDTH;

always @(posedge clk or negedge rst) begin
    if (rst) begin
        clk <= 0;
        rst <= 0;
        tag_out = 0;
        data_out = 0;
        valid = 0;
        error = 0;
        stored_index = 0;
        stored_offset = 0;
        stored_tag = 0;
        stored_data = 0;
    end else begin
        stored_index = index;
        stored_offset = offset;
        stored_tag = tag_in;
        stored_data = data_in;
    end
end

always @(*) begin
    // Compute index
    [INDEX_WIDTH-1:0] index_result = stored_index;
    // Compute offset
    [OFFSET_WIDTH-1:0] offset_result = stored_offset;
    // Tag out
    tag_out = tag_in;
    // Data out
    data_out = data_in;
    // Valid
    valid = 1'b1;
    // Error
    error = 0;

    // Check offset alignment
    if (offset_result[0] == 1'b1) begin
        valid = 0;
        error = 1;
        data_out = 0;
        tag_out = 0;
    end

    // Check tag match
    if (comp) begin
        if (tag_match) begin
            hit = 1;
        else begin
            hit = 0;
            error = 1; // tag mismatch
        end
    end else begin
        hit = 0;
        error = 0;
    end
end

always @(negedge clk) begin
    // Reset on reset event
    if (rst) begin
        tag_out <= 0;
        data_out <= 0;
        valid <= 0;
        error <= 0;
        stored_index <= 0;
        stored_offset <= 0;
        stored_tag <= 0;
        stored_data <= 0;
    end else begin
        // Update state
        if (enable) begin
            if (write) begin
                // Write operation
                if (comp) begin
                    // Write compare
                    if (tag_match) begin
                        data_out <= data_in;
                        valid <= 1;
                        dirty <= 1;
                    end else begin
                        // Write miss, invalid
                        valid <= 0;
                        error <= 1;
                    end
                end else begin
                    // Write no-op?
                end
            end else begin
                // Read
                // But we already handled write above
            end
        end
    end
end

endmodule
