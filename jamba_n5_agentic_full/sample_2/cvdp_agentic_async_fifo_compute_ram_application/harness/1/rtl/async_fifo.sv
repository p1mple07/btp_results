module async_fifo (
    input   logic i_wr_clk,
    input   logic i_wr_rst_n,
    input   logic i_wr_en,
    input   logic i_wr_data,
    output logic o_fifo_full,
    input   logic i_rd_clk,
    input   logic i_rd_rst_n,
    input   logic i_rd_en,
    output logic o_rd_data,
    output logic o_fifo_empty,
    input   logic i_rd_grey_addr,
    output reg w_wr_grey_addr,
    input   logic i_rd_ptr_sync,
    output reg w_wr_ptr_sync,
    input   logic i_rd_en,
    output logic o_rd_en
);

    // Submodules:
    localparam int ADDR_WIDTH = 16; // default address width
    localparam int DATA_WIDTH = 32; // default data width

    // Instantiate submodules
    read_to_write_pointer_sync #(ADDR_WIDTH) rtwps (
        .o_rd_ptr_sync(rtwps_rd_ptr_sync),
        .i_rd_grey_addr(rtwps_rd_grey_addr),
        .i_rd_ptr_sync(rtwps_rd_ptr_sync),
        .o_rd_ptr_sync(rtwps_rd_ptr_sync)
    );

    write_to_read_pointer_sync #(ADDR_WIDTH) wrtp (
        .i_rd_clk(rtwps_rd_ptr_sync),
        .i_rd_rst_n(rtwps_rd_rst_n),
        .i_wr_grey_addr(rtwps_wr_grey_addr),
        .o_wr_ptr_sync(rtwp_wr_ptr_sync)
    );

    wptr_full #(ADDR_WIDTH) wptr_full_inst (
        .i_wr_clk(i_wr_clk),
        .i_wr_rst_n(i_wr_rst_n),
        .i_wr_en(i_wr_en),
        .i_rd_ptr_sync(rtwps_rd_ptr_sync),
        .o_fifo_full(o_fifo_full),
        .o_wr_bin_addr(w_wr_bin_addr),
        .o_wr_grey_addr(w_wr_grey_addr)
    );

    fifo_memory #(DATA_WIDTH, ADDR_WIDTH) fifo_mem (
        .i_wr_clk(i_wr_clk),
        .i_wr_clk_en(i_wr_en),
        .i_wr_addr(w_wr_bin_addr),
        .i_wr_data(i_wr_data),
        .i_wr_full(o_fifo_full),
        .i_rd_clk(i_rd_clk),
        .i_rd_clk_en(i_rd_en),
        .i_rd_addr(w_rd_bin_addr),
        .o_rd_data(o_rd_data),
        .o_rd_full(o_fifo_full),
        .o_rd_bin_addr(w_rd_bin_addr),
        .o_rd_grey_addr(w_rd_grey_addr)
    );

    rptr_empty #(ADDR_WIDTH) rptr_empty_inst (
        .i_rd_clk(i_rd_clk),
        .i_rd_rst_n(i_rd_rst_n),
        .i_rd_en(i_rd_en),
        .i_wr_ptr_sync(w_wr_ptr_sync),
        .o_fifo_empty(o_fifo_empty),
        .o_rd_bin_addr(w_rd_bin_addr),
        .o_rd_grey_addr(w_rd_grey_addr)
    );

    // Output ports
    assign o_fifo_full = o_fifo_full_int;
    assign o_fifo_empty = o_fifo_empty_int;

endmodule
