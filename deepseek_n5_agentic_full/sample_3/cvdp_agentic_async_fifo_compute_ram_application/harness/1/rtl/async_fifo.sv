Module declaration
module async_fifo
    #(
        parameter p_data_width = 8,
        parameter p_addr_width = 16
    )

    // Top-level ports
    input wire [p_addr_width:0] w_addr,
    input wire [p_addr_width:0] r_addr,
    input wire [p_data_width:0] w_data,
    input wire w clocks,
    input wire [p_data_width:0] r_data,
    input wire [p_addr_width:0] w_ptr_sync,
    input wire [p_addr_width:0] r_ptr_sync,
    input wire wr_en,
    input wire rd_en,

    // Configuration parameters
    parameter p_data_width = 8,
    parameter p_addr_width = 16,

    // Instantiate submodules
    fifo_memory #(p_data_width, p_addr_width) fifo_memory_inst (
        .i_wr_clk(i_wr_clk),
        .i_wr_clk_en(i_wr_en),
        .i_wr_addr(w_addr),
        .i_wr_data(w_data),
        .i_wr_full(w_full),
        .i_rd_clk(r_clock),
        .i_rd_clk_en(r_en),
        .i_rd_addr(r_addr),
        .o_rd_data(r_data)
    );

    read_to_write_pointer_sync #(p_addr_width) rw_ptr_sync_inst (
        .i_rd_clk(r_clock),
        .i_rd_rst_n(rst_n),
        .i_wr_grey_addr(w_addr),
        .o_rd_ptr_sync(w_ptr_sync)
    );

    write_to_read_pointer_sync #(p_addr_width) wr_ptr_sync_inst (
        .i_rd_clk(r_clock),
        .i_rd_rst_n(rst_n),
        .i_wr_grey_addr(w_addr),
        .o_wr_ptr_sync(r_ptr_sync)
    );

    wptr_full #(p_addr_width) wptr_full_inst (
        .i_wr_clk(i_wr_clk),
        .i_wr_rst_n(wrst_n),
        .i_wr_en(wr_en),
        .i_rd_ptr_sync(w_ptr_sync),
        .o_fifo_full(full_flag),
        .o_wr_bin_addr(w_addr),
        .o_wr_grey_addr(w_addr)
    );

    rptr_empty #(p_addr_width) rptr_empty_inst (
        .i_rd_clk(r_clock),
        .i_rd_rst_n(rst_n),
        .i_rd_en(rd_en),
        .i_wr_ptr_sync(r_ptr_sync),
        .o_fifo_empty(empty_flag),
        .o_rd_bin_addr(r_addr),
        .o_rd_grey_addr(r_addr)
    );

endmodule