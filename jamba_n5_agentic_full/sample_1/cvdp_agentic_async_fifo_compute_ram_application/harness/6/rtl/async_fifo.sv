module async_fifo (
    input    wire [p_addr_width-1:0] p_addr,
    input    wire p_wr_en,
    input    logic p_wr_clk,
    input    logic p_wr_rst_n,
    input    wire p_rd_en,
    input    logic p_rd_clk,
    input    logic p_rd_rst_n,
    output  wire p_data,
    output  logic p_wr_en,
    output  logic p_wr_clk,
    output  logic p_wr_rst_n,
    output  wire p_rd_en,
    output  wire p_rd_clk,
    output  logic p_rd_rst_n,
    output  wire p_data_out
);

// Instantiate read_to_write_pointer_sync
module read_to_write_pointer_sync (
    input p_addr_width,
    input wire i_wr_clk,
    input wire i_wr_rst_n,
    input wire [p_addr_width:0] i_rd_grey_addr,
    output reg o_rd_ptr_sync
);

// Instantiate write_to_read_pointer_sync
module write_to_read_pointer_sync (
    input p_addr_width,
    input wire i_rd_clk,
    input wire i_rd_rst_n,
    input wire [p_addr_width:0] i_wr_grey_addr,
    output reg o_wr_ptr_sync
);

// Instantiate wptr_full
module wptr_full (
    input p_addr_width,
    output o_fifo_full,
    output o_wr_bin_addr,
    output o_wr_grey_addr
);

// Instantiate fifo_memory
module fifo_memory (
    input    wire [p_addr_width-1:0] p_addr,
    input    wire p_wr_en,
    input    logic p_wr_clk,
    input    logic p_wr_rst_n,
    input    wire p_rd_en,
    input    logic p_rd_clk,
    input    logic p_rd_rst_n,
    output  wire p_data,
    output  logic p_wr_en,
    output  logic p_wr_clk,
    output  logic p_wr_rst_n,
    output  wire p_rd_en,
    output  wire p_rd_clk,
    output  logic p_rd_rst_n,
    output  wire p_data_out
);

// Instantiate rptr_empty
module rptr_empty (
    input p_addr_width,
    input wire i_rd_clk,
    input wire i_rd_rst_n,
    input wire [p_addr_width:0] i_wr_ptr_sync,
    output reg o_fifo_empty,
    output wire [p_addr_width-1:0] o_rd_bin_addr,
    output reg [p_addr_width:0] o_rd_grey_addr
);

endmodule
