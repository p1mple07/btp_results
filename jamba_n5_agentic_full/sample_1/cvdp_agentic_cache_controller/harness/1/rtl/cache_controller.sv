module cache_controller (
    input         clk,
    input         reset,
    input [31:0] address,
    input         write_data,
    input         read,
    input         write,
    input         read_data,
    input         hit,
    input         miss,
    input         mem_write,
    input         mem_address,
    input         mem_write_data,
    input         mem_read_data,
    output reg    mem_ready,
    output reg    [31:0] mem_read_data
);

reg         clk_i;
reg         reset_i;
reg [31:0]  cache_array [0:31];
wire        tag_match;
wire        tag_compare;
wire        hit_flag;
wire        write_back_required;

always @(posedge clk) begin
    if (reset) begin
        clk_i <= 0;
        reset_i <= 1;
        cache_array[0:31] <= 0;
        tag_match <= 1'b0;
        tag_compare <= 1'b0;
        hit_flag <= 1'b0;
        write_back_required <= 1'b0;
    end else begin
        clk_i <= clk;
        reset_i <= 0;
        tag_match <= address[5:0] == (cache_array[0:31][5:0]);
        tag_compare <= address[5:0] == (cache_array[0:31][5:0]);
        hit_flag <= tag_match && (cache_array[0:31][31:0] == write_data);
        write_back_required <= false;
    end
end

always @(*) begin
    if (write) begin
        // Write through policy: write to memory and cache
        if (mem_write) begin
            mem_write_data <= write_data;
            mem_read_data <= 32'b0;
            mem_ready <= 0;
        end
        // Update cache
        if (address[5:0] == mem_address[5:0]) begin
            cache_array[address[5:0]] = write_data;
        end
        write_back_required = true;
    end else begin
        // Just read
        if (read) begin
            if (tag_match && cache_array[address[5:0]] == read_data) begin
                hit_flag <= 1;
                mem_ready <= 1;
            end else begin
                hit_flag <= 0;
                mem_ready <= 0;
            end
        end
    end
end

assign mem_ready = !mem_ready;

endmodule
