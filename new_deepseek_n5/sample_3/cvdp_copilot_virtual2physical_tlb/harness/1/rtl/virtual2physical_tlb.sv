module virtual2physical_tlb #(parameter ADDR_WIDTH = 8, PAGE_WIDTH = 8, TLB_SIZE = 4, PAGE_TABLE_SIZE = 16) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] virtual_address,
    output [PAGE_WIDTH-1:0] physical_address,
    output hit, miss
);
    wire tlb_write_enable, flush, ready;
    wire [PAGE_WIDTH-1:0] page_table_entry;
    wire [TLB_SIZE-1:0] valid_bits;
    wire [TLB_SIZE-1:0] replacement_index;
    wire [ADDR_WIDTH-1:0] tag;
    reg [ADDR_WIDTH-1:0] virtual_tags[TLB_SIZE-1:0];
    reg [PAGE_WIDTH-1:0] physical_pages[TLB_SIZE-1:0];
    reg [TLB_SIZE-1:0] valid_bits;
    reg [log2(TLB_SIZE)-1:0] replacement_index;
    integer i;
    integer idx;

    always_comb begin
        tag = virtual_address[ADDR_WIDTH-4:0];
        hit = 0;
        miss = 1;
        physical_address = 0;

        if (virtual_address == 0) begin
            hit = 1;
            physical_address = 0;
        end else if (valid_bits[replacement_index] == 1) begin
            // Hit case
            physical_address = physical_pages[replacement_index];
            hit = 1;
            valid_bits[replacement_index] = 0;
        end else begin
            // Miss case
            miss = 1;
            page_table_entry = page_table_handler(virtual_address);
            physical_address = (page_table_entry << (ADDR_WIDTH - PAGE_WIDTH)) + virtual_address[PAGE_WIDTH:0];
            valid_bits[replacement_index] = 1;
        end
    end

    // TLB Replacement Logic
    always_comb begin
        if (valid_bits[replacement_index] == 0) begin
            idx = replacement_index + 1;
            replacement_index = idx & (TLB_SIZE - 1);
        end
    end

    module TLB #(parameter TLB_SIZE = 4, ADDR_WIDTH = 8, PAGE_WIDTH = 8) (
        input clk,
        input reset,
        input [ADDR_WIDTH-1:0] virtual_address,
        input tlb_write_enable,
        input flush,
        input [PAGE_WIDTH-1:0] page_table_entry,
        output reg [PAGE_WIDTH-1:0] physical_address,
        output reg hit,
        output reg miss
    );
        reg [ADDR_WIDTH-1:0] virtual_tags[TLB_SIZE-1:0];
        reg [PAGE_WIDTH-1:0] physical_pages[TLB_SIZE-1:0];
        reg [TLB_SIZE-1:0] valid_bits;
        reg [log2(TLB_SIZE)-1:0] replacement_index;
        integer i;

        always_comb begin
            tag = virtual_address[ADDR_WIDTH-4:0];
            hit = 0;
            miss = 1;
            physical_address = 0;

            if (virtual_address == 0) begin
                hit = 1;
                physical_address = 0;
            end else if (valid_bits[replacement_index] == 1) begin
                // Hit case
                physical_address = physical_pages[replacement_index];
                hit = 1;
                valid_bits[replacement_index] = 0;
            end else begin
                // Miss case
                miss = 1;
                page_table_entry = page_table_handler(virtual_address);
                physical_address = (page_table_entry << (ADDR_WIDTH - PAGE_WIDTH)) + virtual_address[PAGE_WIDTH:0];
                valid_bits[replacement_index] = 1;
            end
        end

        // TLB Replacement Logic
        always_comb begin
            if (valid_bits[replacement_index] == 0) begin
                idx = replacement_index + 1;
                replacement_index = idx & (TLB_SIZE - 1);
            end
        end
    endmodule

    module PageTableHandler #(parameter ADDR_WIDTH = 8, PAGE_WIDTH = 8, PAGE_TABLE_SIZE = 16) (
        input clk,
        input reset,
        input miss,
        input [ADDR_WIDTH-1:0] virtual_page,
        output reg [PAGE_WIDTH-1:0] page_table_entry,
        output reg ready
    );
        reg [PAGE_WIDTH-1:0] page_table_memory [0:PAGE_TABLE_SIZE-1];
        assign page_table_entry = page_table_memory[virtual_page];

        always @(posedge clk or posedge reset) begin
            if (reset) begin
                page_table_memory[0] <= 8'h0;
                page_table_memory[1] <= 8'h1;
                page_table_memory[2] <= 8'h2;
                page_table_memory[3] <= 8'h3;
                page_table_memory[4] <= 8'h4;
                page_table_memory[5] <= 8'h5;
                page_table_memory[6] <= 8'h6;
                page_table_memory[7] <= 8'h7;
                page_table_memory[8] <= 8'h8;
                page_table_memory[9] <= 8'h9;
                page_table_memory[10] <= 8'hA;
                page_table_memory[11] <= 8'hB;
                page_table_memory[12] <= 8'hC;
                page_table_memory[13] <= 8'hD;
                page_table_memory[14] <= 8'hE;
                page_table_memory[15] <= 8'hF;
                ready <= 0;
            end else if (miss) begin
                ready <= 1;
            end else begin
                ready <= 0;
            end
        end
    endmodule

    module ControlUnit (
        input clk,
        input reset,
        input hit,
        input miss,
        input ready,
        output reg tlb_write_enable,
        output reg flush
    );
        reg [1:0] state;
        reg [1:0] tag;
        reg [1:0] page_table_entry;
        reg [1:0] physical_address;
        reg [1:0] valid_bits;
        reg [1:0] replacement_index;

        state = IDLE;
        always_comb begin
            if (reset) begin
                state = IDLE;
                tlb_write_enable = 0;
                flush = 0;
                tag = 0;
                page_table_entry = 0;
                physical_address = 0;
                valid_bits = 0;
                replacement_index = 0;
            end else if (hit) begin
                state = UPDATE;
                tlb_write_enable = 1;
                flush = 0;
            end else if (miss) begin
                state = FETCH;
                tlb_write_enable = 0;
                flush = 0;
            end else if (ready) begin
                state = UPDATE;
                tlb_write_enable = 1;
                flush = 0;
            end else begin
                state = IDLE;
                tlb_write_enable = 0;
                flush = 0;
            end
        end
    endmodule