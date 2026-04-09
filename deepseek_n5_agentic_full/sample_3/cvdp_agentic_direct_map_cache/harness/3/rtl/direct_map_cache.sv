module direct_map_cache #(
    parameter CACHE_SIZE = 256,
    parameter DATA_WIDTH = 16,
    parameter TAG_WIDTH = 5,
    parameter OFFSET_WIDTH = 3,
    localparameter N = 2
) (
    input wire enable,
    input [N-1:0] index,
    input [OFFSET_WIDTH-1:0] offset,
    input comp,
    input write,
    input [TAG_WIDTH-1:0] tag_in,
    input [DATA_WIDTH-1:0] data_in,
    input valid_in,
    input [DATA_WIDTH-1:0] data_out,
    input [TAG_WIDTH-1:0] tag_out,
    input valid,
    input error
    output tag_out,
    output [DATA_WIDTH-1:0] data_out,
    output valid,
    output error
    integer victim_way;
    reg [N-1:0] valid_ways [CACHE_SIZE-1:0],
    reg [N-1:0] dirty_ways [CACHE_SIZE-1:0],
    reg tag_ways[N] [CACHE_SIZE-1:0],
    reg data_mem_ways[N] [CACHE_SIZE-1:0][OFFSET_WIDTH:0]
);

    // Cache line definitions
    reg [TAG_WIDTH-1:0] tags [CACHE_SIZE-1:0][N:0];
    reg [DATA_WIDTH-1:0] data_mem [CACHE_SIZE-1:0][N:0][OFFSET_WIDTH:0];
    reg valid_bits [CACHE_SIZE-1:0][N:0];
    reg dirty_bits [CACHE_SIZE-1:0][N:0];
    reg i;

    // Sequential logic for cache operations
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < CACHE_SIZE * N; i = i + 1) begin
                valid_bits[i / N][i % N] <= 1'b0;
                dirty_bits[i / N][i % N] <= 1'b0;
            end
            hit <= 1'b0;
            victim_way <= 0;
            dirty <= 1'b0;
            valid <= 1'b0;
            data_out <= {DATA_WIDTH{1'b0}};            
        end else begin
            if (enable) begin
                for (i = 0; i < CACHE_SIZE * N; i = i + 1) begin
                    valid_bits[i / N][i % N] <= 1'b0;
                    dirty_bits[i / N][i % N] <= 1'b0;
                end
                hit <= 1'b0;
                victim_way <= 0;
                valid <= 1'b0;
                data_out <= {DATA_WIDTH{1'b0}};
            end
        end
    end

    // Other logic...