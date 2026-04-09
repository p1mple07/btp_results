module async_fifo(
    parameter p_data_width = 32,
    parameter p_addr_width = 16
);

    input  wire            i_wr_clk,
           input  wire            i_wr_rst_n,
           input  wire [p_addr_width:0] i_wr_addr,
           input  wire [p_data_width:0] i_wr_data,
           input  wire            i_wr_en,
           input  wire            i_rd_clk,
           input  wire            i_rd_rst_n,
           input  wire [p_addr_width:0] i_rd_addr,
           output reg [p_data_width:0] o_wr_data,
           output reg            o_fifo_full,
           output reg            o_fifo_empty,

    output reg [p_addr_width:0]   w_wr_ptr_sync,
           output reg [p_addr_width:0]   w_rd_ptr_sync,

    output reg [p_addr_width:0+1] o_wr_grey_addr,
           output reg [p_addr_width:0+1] o_rd_grey_addr
);

    // Instantiate submodules
    read_to_write_pointer_sync #(p_addr_width) read_to_write_pointer_sync_inst (
        .i_wr_clk(i_wr_clk),
        .i_wr_rst_n(i_wr_rst_n),
        .i_rd_grey_addr(w_rd_grey_addr),
        .o_rd_ptr_sync(w_rd_ptr_sync),
        .i_wr_addr(w_wr_bin_addr),
        .o_wr_ptr_sync(w_wr_ptr_sync)
    );

    write_to_read_pointer_sync #(p_addr_width) write_to_read_pointer_sync_inst (
        .i_rd_clk(i_rd_clk),
        .i_rd_rst_n(i_rd_rst_n),
        .i_wr_grey_addr(w_wr_grey_addr),
        .o_wr_ptr_sync(w_wr_ptr_sync),
        .i_rd_addr(w_rd_bin_addr),
        .o_rd_ptr_sync(r_rd_ptr_sync)
    );

    fifo_memory #(p_data_width, p_addr_width) fifo_memory_inst (
        .i_wr_clk(i_wr_clk),
        .i_wr_clk_en(i_wr_en),
        .i_wr_addr(w_wr_bin_addr),
        .i_wr_data(i_wr_data),
        .i_wr_full(fifo_full),
        .i_rd_clk(i_rd_clk),
        .i_rd_clk_en(i_rd_en),
        .i_rd_addr(w_rd_bin_addr),
        .o_rd_data(o_wr_data)
    );

    rptr_empty #(p_addr_width) rptr_empty_inst (
        .i_rd_clk(i_rd_clk),
        .i_rd_rst_n(i_rd_rst_n),
        .i_rd_en(i_rd_en),
        .i_wr_ptr_sync(w_wr_ptr_sync),
        .o_fifo_empty(fifo_empty),
        .o_rd_bin_addr(w_rd_bin_addr),
        .o_rd_grey_addr(w_rd_grey_addr)
    );

    wptr_full #(p_addr_width) wptr_full_inst (
        .i_wr_clk(i_wr_clk),
        .i_wr_rst_n(i_wr_rst_n),
        .i_wr_en(i_wr_en),
        .i_rd_ptr_sync(r_rd_ptr_sync),
        .o_fifo_full(fifo_full),
        .o_wr_bin_addr(w_wr_bin_addr),
        .o_wr_grey_addr(w_wr_grey_addr)
    );
endmodule