module direct_map_cache #(
    parameter CACHE_SIZE   = 256,
    parameter DATA_WIDTH   = 16,
    parameter TAG_WIDTH    = 5,
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
    output [DATA_WIDTH-1:0] data_out,
    output hit,
    output dirty,
    output tag_out,
    output data_out,
    output valid,
    output error
);

    reg enable;
    reg [INDEX_WIDTH-1:0] index;
    reg [OFFSET_WIDTH-1:0] offset;
    reg comp;
    reg write;
    reg [TAG_WIDTH-1:0] tag_in;
    reg [DATA_WIDTH-1:0] data_in;
    reg valid_in;
    reg clk;
    reg rst;

    wire hit;
    wire dirty;
    wire [TAG_WIDTH-1:0] tag_out;
    wire [DATA_WIDTH-1:0] data_out;
    wire valid;
    wire error;

    always_ff @(posedge clk) begin
        enable <= enable;
        index <= index;
        offset <= offset;
        comp <= comp;
        write <= write;
        tag_in <= tag_in;
        data_in <= data_in;
        valid_in <= valid_in;

        hit = (comp && tag_in == stored_tag && write);
        dirty = (comp && write && hit);
        tag_out = stored_tag;
        data_out = data_in;
        valid = (enable && (hit || valid_in));
        error = (offset[0] == 1'b1);
    end

    task reset();
        begin
            rst = 1;
            enable = 0;
            index = 0;
            offset = 0;
            comp = 0;
            write = 0;
            tag_in = 0;
            data_in = 0;
            valid_in = 0;

            @(negedge clk);
            rst = 0;
            @(negedge clk);
            $display("\n[RESET] Completed at time %0t", $time);
        end
    endtask

endmodule
