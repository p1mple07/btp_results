module async_fifo #(
    parameter P_DATA_WIDTH = 32,
    parameter P_ADDR_WIDTH = 16
) (
    input  wire i_wr_clk, i_wr_rst_n, i_wr_en, i_wr_data,
    input  wire i_rd_clk, i_rd_rst_n, i_rd_en, i_rd_data,
    output reg o_fifo_full,
    output reg o_fifo_empty,
    output reg [P_ADDR_WIDTH-1:0] o_wr_ptr_sync,
    output reg [P_ADDR_WIDTH-1:0] o_rd_ptr_sync,
    output reg [P_ADDR_WIDTH-1:0] o_rd_bin_addr,
    output reg [P_ADDR_WIDTH-1:0] o_wr_grey_addr,
    output reg [P_ADDR_WIDTH-1:0] o_rd_grey_addr
);

// Read to Write Pointer Sync
instance read_to_write_pointer_sync (
    .p_addr_width(P_ADDR_WIDTH),
    .i_wr_clk(i_wr_clk),
    .i_wr_rst_n(i_wr_rst_n),
    .i_wr_en(i_wr_en),
    .i_wr_data(i_wr_data),
    .o_rd_ptr_sync(o_rd_ptr_sync)
);

// Write to Read Pointer Sync
instance write_to_read_pointer_sync (
    .p_addr_width(P_ADDR_WIDTH),
    .i_rd_clk(i_rd_clk),
    .i_rd_rst_n(i_rd_rst_n),
    .i_wr_grey_addr(o_wr_grey_addr),
    .o_wr_ptr_sync(o_wr_ptr_sync)
);

// Write Pointer Full
instance wptr_full (
    .p_addr_width(P_ADDR_WIDTH),
    .i_wr_clk(i_wr_clk),
    .i_wr_rst_n(i_wr_rst_n),
    .i_wr_en(i_wr_en),
    .i_rd_ptr_sync(o_rd_ptr_sync),
    .o_fifo_full(o_fifo_full),
    .o_wr_bin_addr(o_wr_bin_addr),
    .o_wr_grey_addr(o_wr_grey_addr),
    .o_wr_full(o_fifo_full)
);

// FIFO Memory
instance fifo_memory (
    .p_data_width(P_DATA_WIDTH),
    .p_addr_width(P_ADDR_WIDTH)
);

// Read Pointer Empty
instance rptr_empty (
    .p_addr_width(P_ADDR_WIDTH),
    .i_rd_clk(i_rd_clk),
    .i_rd_rst_n(i_rd_rst_n),
    .i_rd_en(i_rd_en),
    .i_rd_data(i_rd_data),
    .o_wr_ptr_sync(o_wr_ptr_sync),
    .o_rd_ptr_sync(o_rd_ptr_sync),
    .o_rd_bin_addr(o_rd_bin_addr),
    .o_wr_grey_addr(o_wr_grey_addr),
    .o_rd_grey_addr(o_rd_grey_addr)
);

endmodule
