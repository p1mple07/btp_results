Module
module direct_map_cache #(
    parameter CACHE_SIZE = 256,
    parameter DATA_WIDTH = 16,
    parameter TAG_WIDTH = 5,
    parameter OFFSET_WIDTH = 3,
    localparameter N = 2 // Number of ways per set
) (
    input enable, 
    input [7:0] index, 
    input [OFFSET_WIDTH-1:0] offset, 
    input comp, 
    input write, 
    input [TAG_WIDTH-1:0] tag_in, 
    input [DATA_WIDTH-1:0] data_in, 
    input valid_in, 
    input clk, 
    input rst, 
    output [TAG_WIDTH-1:0] tag_out, 
    output [DATA_WIDTH-1:0] data_out, 
    output valid, 
    output error
);

// Internal variables for each way
reg [TAG_WIDTH-1:0] tags0 [CACHE_SIZE-1:0]; // Tags for way 0
reg [TAG_WIDTH-1:0] tags1 [CACHE_SIZE-1:0]; // Tags for way 1
reg [DATA_WIDTH-1:0] data0 [CACHE_SIZE-1:0] [OFFSET_WIDTH:0]; // Data for way 0
reg [DATA_WIDTH-1:0] data1 [CACHE_SIZE-1:0] [OFFSET_WIDTH:0]; // Data for way 1
reg valid_bits0 [CACHE_SIZE-1:0]; // Valid bits for way 0
reg valid_bits1 [CACHE_SIZE-1:0]; // Valid bits for way 1
reg dirty_bits0 [CACHE_SIZE-1:0]; // Dirty bits for way 0
reg dirty_bits1 [CACHE_SIZE-1:0]; // Dirty bits for way 1
wire hit0, hit1; // Hit indicators for each way

// Register for victim-way replacement
reg victimway = 0; // Determines which way to evict

// Sequential logic for cache operations
always @(posedge clk) begin
    if (rst) begin
        // Initialize all registers to 0 on reset
        for (i = 0; i < CACHE_SIZE; i = i + 1) begin
            valid_bits0[i] <= 0;
            dirty_bits0[i] <= 0;
            valid_bits1[i] <= 0;
            dirty_bits1[i] <= 0;
        end
        hit0 <= 0;
        hit1 <= 0;
        data_out <= {DATA_WIDTH{1'b0}};
        valid <= 0;
        error <= 0;
        data_in <= {DATA_WIDTH{1'b0}};

        // Enable starts up
        enable = 1;
        rst = 0;
        continue;
    end

    if (enable) begin
        if (comp) begin
            if (write) begin
                if (offset[0] == 1'b1) begin
                    error <= 1'b1;
                    hit0 <= 1;
                    hit1 <= 1;
                    valid <= 0;
                    data_out <= {DATA_WIDTH{1'b0}};
                end 
                else begin
                    if (tags0[index] == tag_in && valid_bits0[index]) begin
                        hit0 <= 1;
                        data_out <= data0[index][offset[OFFSET_WIDTH-1:1]];
                        dirty_bits0 <= 1'b1;
                        valid_bits0[index] <= valid_in;
                        victimway = 0;
                    end 
                    else if (tags1[index] == tag_in && valid_bits1[index]) begin
                        hit1 <= 1;
                        data_out <= data1[index][offset[OFFSET_WIDTH-1:1]];
                        dirty_bits1 <= 1'b1;
                        valid_bits1[index] <= valid_in;
                        victimway = 1;
                    end 
                    else if (hit0 && hit1) begin
                        if (victimway == 0) begin
                            // Evict way1
                            data1[index][offset[OFFSET_WIDTH-1:1]] <= data0[index][offset[OFFSET_WIDTH-1:1]];
                            valid_bits1[index] <= 0;
                            dirty_bits1[index] <= 0;
                            victimway = 1;
                        else begin
                            // Evict way0
                            data0[index][offset[OFFSET_WIDTH-1:1]] <= data1[index][offset[OFFSET_WIDTH-1:1]];
                            valid_bits0[index] <= 0;
                            dirty_bits0[index] <= 0;
                            victimway = 0;
                        end 
                    end 
                    else if (hit0) begin
                        // Keep way0
                        data1[index][offset[OFFSET_WIDTH-1:1]] <= $zero;
                        valid_bits1[index] <= 0;
                        dirty_bits1[index] <= 0;
                    end 
                    else if (hit1) begin
                        // Keep way1
                        data0[index][offset[OFFSET_WIDTH-1:1]] <= $zero;
                        valid_bits0[index] <= 0;
                        dirty_bits0[index] <= 0;
                    end 
                    else begin
                        // Evict randomly
                        victimway = victimway ^ 1;
                        data1[index][offset[OFFSET_WIDTH-1:1]] <= data0[index][offset[OFFSET_WIDTH-1:1]];
                        valid_bits1[index] <= 0;
                        dirty_bits1[index] <= 0;
                    end 
                end 
            end 
            else begin
                if (write) begin
                    tags0[index] <= tag_in;
                    data0[index][offset[OFFSET_WIDTH-1:1]] <= data_in;
                    valid_bits0[index] <= valid_in;
                    dirty_bits0[index] <= valid_in;
                end 
                if (valid_in) begin
                    tags1[index] <= tag_in;
                    data1[index][offset[OFFSET_WIDTH-1:1]] <= data_in;
                    valid_bits1[index] <= valid_in;
                    dirty_bits1[index] <= valid_in;
                end 
            end 
        end 
        else begin
            // Non-misaligned offset
            if (offset[0] == 1'b1) begin
                error <= 1'b1;
                hit0 <= 1;
                hit1 <= 1;
                valid <= 0;
                data_out <= {DATA_WIDTH{1'b0}};
            end 
            else begin
                valid <= valid_bits0[index] | valid_bits1[index];
                dirty <= dirty_bits0[index] | dirty_bits1[index];
                data_out <= (valid_bits0[index] ? data0[index][offset[OFFSET_WIDTH-1:1]] : $zero) |
                         (valid_bits1[index] ? data1[index][offset[OFFSET_WIDTH-1:1]] : $zero);
                hit0 <= (tags0[index] == tag_in & valid_bits0[index]);
                hit1 <= (tags1[index] == tag_in & valid_bits1[index]);
            end 
        end 
    end 
end 

// Clock generation and initialization
initial begin
    rst = 1;
    $finish;
end 

// Test benches and displays omitted for brevity
// Include appropriate test bench code here...
endmodule