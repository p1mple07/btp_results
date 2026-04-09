module virtual2physical_tlb #(
    parameter ADDR_WIDTH = 8,
    PAGE_WIDTH = 8,
    TLB_SIZE = 4,
    PAGE_TABLE_SIZE = 16
) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] virtual_address,
    output [PAGE_WIDTH-1:0] physical_address,
    output hit, miss
);

    wire tlb_write_enable, flush, ready;
    wire [PAGE_WIDTH-1:0] page_table_entry;
    TLB #(.TLB_SIZE(TLB_SIZE), .ADDR_WIDTH(ADDR_WIDTH), .PAGE_WIDTH(PAGE_WIDTH)) tlb (
        .clk(clk),
        .reset(reset),
        .virtual_address(virtual_address),
        .tlb_write_enable(tlb_write_enable),
        .flush(flush),
        .page_table_entry(page_table_entry),
        .physical_address(physical_address),
        .hit(hit),
        .miss(miss)
    );

    PageTableHandler #(.ADDR_WIDTH(ADDR_WIDTH), .PAGE_WIDTH(PAGE_WIDTH), .PAGE_TABLE_SIZE(PAGE_TABLE_SIZE)) page_table_handler(
        .clk(clk),
        .reset(reset),
        .miss(miss),
        .virtual_page(virtual_address),
        .page_table_entry(page_table_entry),
        .ready(ready)
    );

    ControlUnit control_unit (
        .clk(clk),
        .reset(reset),
        .hit(hit),
        .miss(miss),
        .ready(ready),
        .tlb_write_enable(tlb_write_enable),
        .flush(flush)
    );

endmodule

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
    reg [$clog2(TLB_SIZE)-1:0] replacement_index;

    reg [TLB_SIZE-1:0] matches;
    reg [$clog2(TLB_SIZE)-1:0] replacement_tag;

    always_comb begin
        hit = 0;
        miss = 1;
        physical_address = 0;

        for (int i = 0; i < TLB_SIZE; i++) begin
            if (matches[i]) begin
                hit = 1;
                physical_address = virtual_tags[i];
            end else
                miss = 1;
        end
    end

    assign tlb_write_enable = 1'b0;
    assign flush = 1'b0;
    assign ready = 1'b0;

    always_ff @(posedge clk) begin
        if (reset) begin
            virtual_tags[0] <= 8'b0;
            physical_pages[0] <= 8'b0;
            valid_bits <= 0;
            replacement_index <= 3;
            matches <= 0;
            replacement_tag <= 8'b0;
        end else begin
            virtual_tags[replacement_index] = virtual_address;
            physical_pages[replacement_index] = physical_address;
            valid_bits[replacement_index] = 1;
            replacement_index <= replacement_index + 1 mod TLB_SIZE;
            matches <= 0;
            replacement_tag <= 8'b0;
        end
    end

endmodule

module PageTableHandler #(
    parameter ADDR_WIDTH = 8,
    PAGE_WIDTH = 8,
    PAGE_TABLE_SIZE = 16
) (
    input clk,
    input reset,
    input miss,
    input [ADDR_WIDTH-1:0] virtual_page,
    output reg [PAGE_WIDTH-1:0] page_table_entry,
    output reg ready
);

    reg [PAGE_WIDTH-1:0] page_table_memory [0:PAGE_TABLE_SIZE-1];
    reg [CLOG2(PAGE_TABLE_SIZE)-1:0] addr_list;

    always @(posedge clk) begin
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
            page_table_memory[10] <= 8'ha;
            page_table_memory[11] <= 8'hb;
            page_table_memory[12] <= 8'hc;
            page_table_memory[13] <= 8'hd;
            page_table_memory[14] <= 8'he;
            page_table_memory[15] <= 8'hf;
            ready <= 0;
        end else if (miss) begin
            addr_list = virtual_page;
            page_table_entry = page_table_memory[addr_list];
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

    localparam IDLE = 2'b00,
                 FETCH = 2'b01,
                 UPDATE = 2'b10;

    always_comb begin
        state = IDLE;
    end

    always_ff @(posedge clk) begin
        case(state)
            IDLE: begin
                if (ready) begin
                    state <= FETCH;
                end else
                    state <= IDLE;
            end

            FETCH: begin
                state <= UPDATE;
            end

            UPDATE: begin
                if (flush) begin
                    state <= IDLE;
                end else
                    state <= FETCH;
                end
            end
        endcase
    end

    output reg tlb_write_enable = 1'b0;
    output reg flush = 1'b0;

endmodule
