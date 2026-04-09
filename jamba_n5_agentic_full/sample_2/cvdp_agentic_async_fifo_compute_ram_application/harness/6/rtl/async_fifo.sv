module async_fifo (
    input wire i_wr_clk,
    input wire i_wr_rst_n,
    input wire i_wr_en,
    input wire i_wr_data,
    output wire o_fifo_full,
    output reg o_wr_ptr_sync,

    input wire i_rd_clk,
    input wire i_rd_rst_n,
    input wire i_rd_en,
    output wire o_rd_data,
    output reg o_fifo_empty
);

    // Read-to-Write pointer synchronization
    inst read_to_write_pointer_sync u_rw (
        .p_addr_width(p_addr_width),
        .i_wr_clk(i_wr_clk),
        .i_wr_rst_n(i_wr_rst_n),
        .i_wr_en(i_wr_en),
        .i_wr_data(i_wr_data),
        .o_wr_ptr_sync(o_wr_ptr_sync)
    );

    // Write-to-Read pointer synchronization
    inst write_to_read_pointer_sync u_ptr_sync (
        .p_addr_width(p_addr_width),
        .i_rd_clk(i_rd_clk),
        .i_rd_rst_n(i_rd_rst_n),
        .i_rd_en(i_rd_en),
        .o_wr_ptr_sync(o_wr_ptr_sync)
    );

    // Write FIFO logic
    inst wptr_full u_wptr_full (
        .p_addr_width(p_addr_width),
        .i_wr_clk(i_wr_clk),
        .i_wr_rst_n(i_wr_rst_n),
        .i_wr_en(i_wr_en),
        .i_rd_ptr_sync(o_rd_ptr_sync),
        .o_fifo_full(o_fifo_full)
    );

    // Memory storage
    inst fifo_memory u_mem (
        .p_data_width(p_data_width),
        .p_addr_width(p_addr_width),
        .p_depth(p_depth),
        .p_wr_clk(i_wr_clk),
        .p_wr_clk_en(i_wr_clk_en),
        .p_wr_addr(i_wr_addr),
        .p_wr_data(i_wr_data),
        .p_wr_full(o_fifo_full),
        .p_rd_clk(i_rd_clk),
        .p_rd_clk_en(i_rd_clk_en),
        .p_rd_addr(i_rd_addr),
        .p_rd_data(o_rd_data),
        .p_rd_full(o_fifo_full),
        .p_rd_rst_n(i_rd_rst_n),
        .p_rd_rst_n_n(i_rd_rst_n_n),
        .p_rd_en(i_rd_en),
        .p_rd_en_n(i_rd_en_n),
        .o_rd_data(o_rd_data),
        .o_rd_full(o_fifo_full),
        .o_rd_rst_n(i_rd_rst_n_n)
    );

    // Read pointer emptying
    inst rptr_empty u_rptr_empty (
        .p_addr_width(p_addr_width),
        .i_rd_clk(i_rd_clk),
        .i_rd_rst_n(i_rd_rst_n),
        .i_rd_en(i_rd_en),
        .o_rd_bin_addr(o_rd_bin_addr),
        .o_rd_grey_addr(o_rd_grey_addr)
    );

endmodule
