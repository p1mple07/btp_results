module virtual2physical_tlb #(
    parameter ADDR_WIDTH = 8,
    parameter PAGE_WIDTH = 8,
    parameter TLB_SIZE = 4,
    parameter PAGE_TABLE_SIZE = 16
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
