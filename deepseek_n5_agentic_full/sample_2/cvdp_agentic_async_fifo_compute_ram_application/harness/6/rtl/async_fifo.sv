module async_fifo
    #(
        parameter p_data_width = 32,
        parameter p_addr_width = 16
    )
    (
        input wire i_wr_clk,  // Write clock
        input wire i_wr_rst_n, // Write reset (active low)
        input wire i_wr_en,   // Write enable
        input wire [p_addr_width:0] i_wr_addr,    // Write address
        input wire [p_data_width-1:0] i_wr_data,  // Write data
        input wire i_rd_clk,     // Read clock
        input wire i_rd_rst_n,   // Read reset (active low)
        input wire i_rd_en,     // Read enable
        input wire [p_addr_width:0] i_rd_addr,    // Read address
        output wire [p_data_width-1:0] o_rd_data  // Read data
    );

    // Calculate the depth of the FIFO based on the address size
    localparam p_depth = 1 << p_addr_width;

    // Instantiate the components
    fifo_memory instantiate(
        p_data_width = p_data_width,
        p_addr_width = p_addr_width
    ) (
        i_wr_clk,
        i_wr_clk_en,
        i_wr_addr,
        i_wr_data,
        i_wr_full,
        i_rd_clk,
        i_rd_clk_en,
        i_rd_addr,
        o_rd_data
    );

    wptr_full instantiate(
        p_addr_width = p_addr_width
    ) (
        i_wr_clk,
        i_wr_rst_n,
        i_wr_en,
        i_rd_ptr_sync,
        o_fifo_full,
        o_wr_bin_addr,
        o_wr_grey_addr
    );

    read_to_write_pointer_sync instantiate(
        p_addr_width = p_addr_width
    ) (
        i_wr_clk,
        i_wr_rst_n,
        i_rd_grey_addr,
        o_rd_ptr_sync
    );

    write_to_read_pointer_sync instantiate(
        p_addr_width = p_addr_width
    ) (
        i_rd_clk,
        i_rd_rst_n,
        i_wr_grey_addr,
        o_wr_ptr_sync
    );

    rptr_empty instantiate(
        p_addr_width = p_addr_width
    ) (
        i_rd_clk,
        i_rd_rst_n,
        i_rd_en,
        i_wr_ptr_sync,
        o_fifo_empty,
        o_rd_bin_addr,
        o_rd_grey_addr
    );
endmodule