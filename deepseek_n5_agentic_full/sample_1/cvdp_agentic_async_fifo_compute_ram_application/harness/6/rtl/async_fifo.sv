module async_fifo (
    # Parameters from FIFO specification
    parameter p_data_width = 32,
    parameter p_addr_width = 16
)

    # Port definitions from FIFO specification
    input wire [p_data_width-1:0] i_wr_data,
    input wire [p_addr_width-1:0] i_wr_addr,
    input wire i_wr_rst_n,
    input wire [p_data_width-1:0] o_wr_data,
    input wire [p_addr_width-1:0] o_wr_addr,

    output wire [p_data_width-1:0] o_fifo_full,
    output wire [p_addr_width-1:0] o_fifo_empty

    # Internal references to child modules
    reference fifo_memory (
        p_data_width,
        p_addr_width,
        i_wr_clk = i_wr_clk,
        i_wr_clk_en = i_wr_rst_n,
        i_wr_addr = i_wr_addr,
        i_wr_data = i_wr_data,
        i_wr_full = i_wr_rst_n,
        i_rd_clk = i_rd_clk,
        i_rd_clk_en = i_rd_rst_n,
        i_rd_addr = i_rd_addr,
        o_rd_data = o_wr_data
    );

    reference read_to_write_pointer_sync (
        p_addr_width,
        i_wr_clk = i_wr_clk,
        i_wr_rst_n = i_wr_rst_n,
        i_rd_grey_addr = i_rd_addr,
        o_rd_ptr_sync = o_wr_ptr_sync
    );

    reference write_to_read_pointer_sync (
        p_addr_width,
        i_rd_clk = i_rd_clk,
        i_rd_rst_n = i_rd_rst_n,
        i_wr_grey_addr = o_wr_ptr_sync,
        o_wr_ptr_sync = o_wr_ptr_sync
    );

    reference wptr_full (
        p_addr_width,
        i_wr_clk = i_wr_clk,
        i_wr_rst_n = i_wr_rst_n,
        i_wr_en = i_wr_rst_n,
        i_rd_ptr_sync = o_wr_ptr_sync,
        o_fifo_full = o_fifo_full,
        o_wr_bin_addr = o_wr_addr,
        o_wr_grey_addr = o_wr_addr
    );

    reference rptr_empty (
        p_addr_width,
        i_rd_clk = i_rd_clk,
        i_rd_rst_n = i_rd_rst_n,
        i_rd_en = i_rd_rst_n,
        i_wr_ptr_sync = o_wr_ptr_sync,
        o_fifo_empty = o_fifo_empty,
        o_rd_bin_addr = o_wr_addr,
        o_rd_grey_addr = o_wr_addr
    );
    
    # Connect FIFO ports
    i_wr_clk = i_wr_clk;
    o_wr_addr = o_wr_addr;
};

module read_to_write_pointer_sync 
    # Parameters from FIFO specification
    # (same as above)

    # (same implementation as given earlier)
    ;
    
module write_to_read_pointer_sync 
    # Parameters from FIFO specification
    # (same as above)

    # (same implementation as given earlier)
    ;
    
module wptr_full 
    # Parameters from FIFO specification
    # (same as above)

    # (same implementation as given earlier)
    ;
    
module rptr_empty 
    # Parameters from FIFO specification
    # (same as above)

    # (same implementation as given earlier)
    ;