module direct_map_cache #(
    parameter CACHE_SIZE = 256,
    parameter DATA_WIDTH = 16,
    parameter TAG_WIDTH = 5,
    parameter OFFSET_WIDTH = 3,
    localparameter N = 2
) (
    input wire enable,
    input wire [N-1:0] index,
    input wire [OFFSET_WIDTH-1:0] offset,
    input wire comp,
    input wire write,
    input wire [TAG_WIDTH-1:0] tag_in,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire [TAG_WIDTH-1:0] tag_out,
    input wire [DATA_WIDTH-1:0] data_out,
    input wire valid,
    output wire error
)

    // Internal registers
    reg [N-1:0] victimway; // Track which way to replace
    reg [N-1:0][TAG_WIDTH-1:0] tags; // Tag storage for each way
    reg [N-1:0][DATA_WIDTH-1:0][OFFSET_WIDTH:0] data_mem; // Data storage for each way
    reg [N-1:0][TAG_WIDTH-1:0] dirty_tags;
    reg [N-1:0][DATA_WIDTH-1:0] valid_bits;

    integer i;

    // Sequential logic
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                valid_bits[i] <= 1'b0;
                dirty_tags[i] <= 1'b0;
            end
            hit <= 1'b0;
            victimway <= 0;
            victimway <= 1'b0;
        else if (enable) begin
            if (offset[0] == 1'b1) begin
                error <= 1'b1;
                victimway <= 0;
                victimway <= 1'b0;
                valid <= 1'b0;
                hit <= 1'b0;
                data_out <= {DATA_WIDTH{1'b0}}; 
            elsif (comp) begin
                if (write) begin
                    if (compare operation) begin
                        if (tags[index] == tag_in) begin
                            hit <= 1'b1;
                            if (valid_bits[index]) valid <= valid_in; 
                            else valid <= 1'b0;
                            
                            if (write) begin
                                data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in;
                                dirty_tags[index] <= 1'b1;
                                valid_bits[index] <= valid_in;
                                victimway <= victimway ^ 1'b0; // Toggle victim-way
                            end
                            tags[index] <= tag_in;
                            valid <= 1'b0;
                            dirty <= 1'b0;
                            data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];
                        end else begin
                            if (valid_bits[index]) begin
                                hit <= 1'b0;
                                tags[index] <= tag_in;
                                data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];
                                valid <= valid_bits[index];
                                dirty <= 0;
                            end else begin
                                hit <= 1'b0;
                                tags[index] <= tag_in;
                                data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];
                                valid <= valid_bits[index];
                                dirty <= 0;
                            end
                        end
                    end else begin
                        if (compare Read) begin
                            if (tags[index] == tag_in & valid_bits[index]) begin
                                hit <= 1'b1;
                                data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];
                                valid <= valid_bits[index];
                                dirty <= dirty_tags[index];
                                victimway <= victimway ^ 1'b0;
                            end else begin
                                if (valid_bits[index]) begin
                                    hit <= 1'b0;
                                    data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];
                                    valid <= valid_bits[index];
                                    dirty <= dirty_tags[index];
                                    victimway <= victimway ^ 1'b0;
                                end else begin
                                    hit <= 1'b0;
                                    data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];
                                    valid <= valid_bits[index];
                                    dirty <= dirty_tags[index];
                                    victimway <= victimway ^ 1'b0;
                                end
                            end
                        end
                    end
                end
                else begin
                    if (write) begin
                        tags[index] <= tag_in;
                        data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in;
                        valid_bits[index] <= valid_in;
                        dirty_tags[index] <= 1'b0;
                        hit <= 1'b0;
                        valid <= 1'b0;
                        victimway <= 0;
                        victimway <= 1'b0;
                    else begin
                        tags[index] <= tag_in;
                        data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in;
                        valid_bits[index] <= valid_in;
                        dirty_tags[index] <= 1'b0;
                        tags[index] <= tag_in;
                        valid <= 1'b0;
                        dirty <= 1'b0;
                        data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];
                    end
                end
            end
        end
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        enable = 0;
        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Initialize cache
        direct_map_cache#(N)(...);
        // ... rest of testbench ...
    end
endmodule