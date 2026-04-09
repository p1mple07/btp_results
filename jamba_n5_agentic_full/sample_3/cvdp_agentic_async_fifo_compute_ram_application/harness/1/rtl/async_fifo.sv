read_to_write_pointer_sync #(p_addr_width) read_to_write_pointer_sync_inst (
    .o_rd_ptr_sync  (w_rd_ptr_sync),
    .i_rd_grey_addr (w_rd_grey_addr),
    .i_wr_clk       (i_wr_clk),
    .i_wr_rst_n     (i_wr_rst_n)
);
