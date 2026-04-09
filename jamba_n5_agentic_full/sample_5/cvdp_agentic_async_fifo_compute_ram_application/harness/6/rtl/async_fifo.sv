module async_fifo (
    input i_wr_clk,
    input i_wr_rst_n,
    input i_wr_en,
    input i_wr_data,
    input i_rd_clk,
    input i_rd_rst_n,
    input i_rd_en,
    input i_rd_data,
    input i_rd_ptr_sync,
    output reg o_wr_ptr_sync,
    output reg o_rd_ptr_sync,
    output reg o_fifo_full,
    output reg o_wr_full,
    output reg o_wr_empty,
    output reg o_rd_empty,
    output reg [p_addr_width-1:0] o_wr_bin_addr,
    output reg [p_addr_width-1:0] o_rd_bin_addr,
    output reg [p_addr_width-1:0] o_wr_grey_addr,
    output reg [p_addr_width-1:0] o_rd_grey_addr
);

rtlsrc.read_to_write_pointer_sync rtws (
    .i_wr_clk(i_wr_clk),
    .i_wr_rst_n(i_wr_rst_n),
    .i_rd_grey_addr(i_rd_ptr_sync),
    .o_rd_ptr_sync(read_ptr_sync)
);

rtlsrc.write_to_read_pointer_sync wrts (
    .i_rd_clk(i_rd_clk),
    .i_rd_rst_n(i_rd_rst_n),
    .i_wr_grey_addr(i_wr_grey_addr),
    .o_wr_ptr_sync(wrts_ptr_sync)
);

wptr_full wpf (
    .p_addr_width(p_addr_width),
    .p_data_width(p_data_width),
    .p_depth(1 << p_addr_width),
    .o_fifo_full(o_fifo_full),
    .o_wr_full(o_wr_full),
    .o_wr_empty(o_wr_empty)
);

fifo_memory fm (
    .p_data_width(p_data_width),
    .p_addr_width(p_addr_width),
    .i_wr_clk(i_wr_clk),
    .i_wr_clk_en(i_wr_en),
    .i_wr_addr(i_wr_data),
    .i_wr_data(i_wr_data),
    .i_wr_full(o_wr_full),
    .i_rd_clk(i_rd_clk),
    .i_rd_clk_en(i_rd_clk_en),
    .i_rd_addr(i_rd_addr),
    .o_rd_data(o_rd_data)
);

rptr_empty rep (
    .p_addr_width(p_addr_width),
    .p_data_width(p_data_width),
    .i_rd_clk(i_rd_clk),
    .i_rd_rst_n(i_rd_rst_n),
    .i_rd_en(i_rd_en),
    .i_wr_ptr_sync(wrts_ptr_sync),
    .o_fifo_empty(o_fifo_empty),
    .o_rd_bin_addr(o_rd_bin_addr),
    .o_rd_grey_addr(o_rd_grey_addr)
);

endmodule
