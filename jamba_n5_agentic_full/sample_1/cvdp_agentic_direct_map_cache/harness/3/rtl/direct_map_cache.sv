`timescale 1ns/1ps

module direct_map_cache #(
    parameter N = 2,                 // Number of ways per set (2-way set-associative)
    parameter CACHE_SIZE = 256,       // Total number of cache lines
    parameter DATA_WIDTH = 16,        // Data width
    parameter TAG_WIDTH = 5,          // Tag width
    parameter OFFSET_WIDTH = 3,       // Offset width
    localparam INDEX_WIDTH = $clog2(CACHE_SIZE) // Index width
) (
    input wire enable,
    input wire [INDEX_WIDTH-1:0] index,
    input wire [OFFSET_WIDTH-1:0] offset,
    input wire comp,
    input wire write,
    input wire [TAG_WIDTH-1:0] tag_in,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire clk,
    input wire rst,
    output reg hit,
    output reg dirty,
    output reg [TAG_WIDTH-1:0] tag_out,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg valid,
    output reg error
);

    // Cache line storage for each way
    reg [TAG_WIDTH-1:0] tags0, tags1;
    reg [DATA_WIDTH-1:0] data0, data1;
    reg [DATA_WIDTH-1:0] data_mem0, data_mem1;
    reg [TAG_WIDTH-1:0] tags0_mask, tags1_mask;
    reg [DATA_WIDTH-1:0] data_out0, data_out1;
    reg valid0, valid1;
    reg dirty0, dirty1;
    integer i;

    // Internal state for victim-way selection
    reg victim_way;

    // Sequential logic for cache operations
    always @(posedge clk) begin
        if (rst) begin
            // Reset all state variables
            tags0.fill(0); tags1.fill(0);
            data0.fill(0); data1.fill(0);
            data_mem0.fill(0); data_mem1.fill(0);
            valid0.set(1'b0); valid1.set(1'b0);
            dirty0.set(1'b0); dirty1.set(1'b0);
            victim_way.set(1'b0);
            hit.set(1'b0); dirty.set(1'b0);
            tag_out.set({0}); data_out.set({0}); valid.set(1'b0); error.set(1'b0);
        end
        else if (enable) begin
            // Check for LSB alignment error
            if (offset[0] == 1'b1) begin
                error.set(1'b1);
                hit.set(1'b0); dirty.set(1'b0); valid.set(1'b0);
                data_out.set({0}); tag_out.set({0});
            end
            else begin
                error.set(1'b0);

                // Compare tag in both ways
                if (tag_in == tag0 && valid0) begin
                    hit.set(1'b1);
                    data_out.set(data0);
                    valid.set(1'b1);
                    dirty.set(1'b0);
                    tag_out.set(tags0);
                end else if (tag_in == tag1 && valid1) begin
                    hit.set(1'b1);
                    data_out.set(data1);
                    valid.set(1'b1);
                    dirty.set(1'b0);
                    tag_out.set(tags1);
                end else begin
                    // Find a victim way
                    victim_way = 1'b0;
                    if (N > 1 && valid0 && !victim_way) begin
                        victim_way = 1'b1;
                    end else if (N > 1 && valid1 && !victim_way) begin
                        victim_way = 1'b0;
                    end

                    // If no victim way available, fall back to the other way
                    if (!victim_way) victim_way = 1'b0;

                    // Update data and tags for the chosen victim way
                    data_out.set(data_mem0[victim_way]);
                    tags_out.set(tags0[victim_way]);
                    valid.set(1'b1);
                    dirty.set(1'b0);
                    tag_out.set(tags0[victim_way]);
                end
            end
        end
        else begin
            // enable = 0 – no operation
            hit.set(1'b0); dirty.set(1'b0); valid.set(1'b0); data_out.set({0}); tag_out.set({0}); data_out.set({0}); valid.set(1'b0);
        end
    end

endmodule
