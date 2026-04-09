module direct_map_cache #(
    parameter N = 2,            // Number of ways per set
    parameter CACHE_SIZE = 256,
    parameter DATA_WIDTH = 16,
    parameter TAG_WIDTH = 5,
    parameter OFFSET_WIDTH = 3,
    localparam INDEX_WIDTH = $clog2(CACHE_SIZE)
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

    // ... rest of the code ...

    // New internal registers for set0 and set1
    reg [TAG_WIDTH-1:0] set0_tag;
    reg [TAG_WIDTH-1:0] set1_tag;
    reg [DATA_WIDTH-1:0] set0_data;
    reg [DATA_WIDTH-1:0] set1_data;
    reg [VALID_WIDTH-1:0] set0_valid;
    reg [VALID_WIDTH-1:0] set1_valid;
    reg [DIRTY_WIDTH-1:0] set0_dirty;
    reg [DIRTY_WIDTH-1:0] set1_dirty;

    integer victim_way;

    // ... existing code ...

    always @(posedge clk) begin
        if (rst) begin
            // Reset all registers
            set0_tag   <= 0; set0_data   <= 0; set0_valid   <= 1'b0;
            set1_tag   <= 0; set1_data   <= 0; set1_valid   <= 1'b0;
            victim_way <= 0;
            hit        <= 1'b0;
            dirty      <= 1'b0;
            data_out   <= {DATA_WIDTH{1'b0}};
        end
        else if (enable) begin
            // Check for LSB alignment error
            if (offset[0] == 1'b1) begin
                error <= 1'b1;
                hit       <= 1'b0;
                dirty      <= 1'b0;
                valid      <= 1'b0;
                data_out   <= {DATA_WIDTH{1'b0}};
            end
            else begin
                error <= 1'b0;

                // Compare read
                if (comp) begin
                    if (write) begin
                        if (tag_in == set0_tag && set0_valid) begin
                            hit <= 1'b1;
                            data_out   <= set0_data;
                            valid      <= set0_valid;
                            dirty      <= set0_dirty;
                            tag_out    <= set0_tag;
                        end
                        else if (tag_in == set1_tag && set1_valid) begin
                            hit <= 1'b1;
                            data_out   <= set1_data;
                            valid      <= set1_valid;
                            dirty      <= set1_dirty;
                            tag_out    <= set1_tag;
                        end
                        else begin
                            hit <= 1'b0;
                            tag_out    <= 0;
                            valid      <= 1'b0;
                            dirty      <= 1'b0;
                            data_out   <= {DATA_WIDTH{1'b0}};
                        end
                    end
                    else begin // write
                        // Compare read
                        if (tag_in == set0_tag && set0_valid) begin
                            hit <= 1'b1;
                            data_out   <= set0_data;
                            valid      <= set0_valid;
                            dirty      <= set0_dirty;
                            tag_out    <= set0_tag;
                        end
                        else if (tag_in == set1_tag && set1_valid) begin
                            hit <= 1'b1;
                            data_out   <= set1_data;
                            valid      <= set1_valid;
                            dirty      <= set1_dirty;
                            tag_out    <= set1_tag;
                        end
                        else begin
                            hit <= 1'b0;
                            tag_out    <= 0;
                            valid      <= 1'b0;
                            dirty      <= 1'b0;
                            data_out   <= {DATA_WIDTH{1'b0}};
                        end
                    end
                end else begin // compare
                    if (write) begin
                        if (tag_in == set0_tag && set0_valid) begin
                            hit <= 1'b1;
                            data_out   <= set0_data;
                            valid      <= set0_valid;
                            dirty      <= set0_dirty;
                            tag_out    <= set0_tag;
                        end
                        else if (tag_in == set1_tag && set1_valid) begin
                            hit <= 1'b1;
                            data_out   <= set1_data;
                            valid      <= set1_valid;
                            dirty      <= set1_dirty;
                            tag_out    <= set1_tag;
                        end
                        else begin
                            hit <= 1'b0;
                            tag_out    <= 0;
                            valid      <= 1'b0;
                            dirty      <= 1'b0;
                            data_out   <= {DATA_WIDTH{1'b0}};
                        end
                    end
                end
            end
        end
        else begin // enable
            // enable
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                valid_bits[i] <= 1'b0;
                dirty_bits[i] <= 1'b0;
            end

            hit      <= 1'b0;
            dirty    <= 1'b0;
            data_out <= {DATA_WIDTH{1'b0}};
            valid    <= 1'b0;
            data_out <= {DATA_WIDTH{1'b0}};
            victim_way <= 0;
            tag_in    <= 0;

            // Simulate random write
            // But we keep original code logic.

        end
    end

endmodule
