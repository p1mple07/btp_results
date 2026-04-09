module async_fifo
    # Parameters defined in the top-level module
    parameter p_data_width = 32,
           p_addr_width = 16;

    // Instantiate the FIFO memory module
    rtl_fifo_memory
        # Configuration parameters
        (p_data_width = p_data_width,
         p_addr_width = p_addr_width)
        # Inputs
        (i_wr_clk = i_wr_clk,
         i_wr_clk_en = i_wr_clk_en,
         i_wr_addr = i_wr_addr,
         i_wr_data = i_wr_data,
         i_wr_full = i_wr_full,
         i_rd_clk = i_rd_clk,
         i_rd_clk_en = i_rd_clk_en,
         i_rd_addr = i_rd_addr,
         o_rd_data = o_rd_data);
    
    // Instantiate the write-to-read pointer sync module
    rtl_write_to_read_pointer_sync
        # Configuration parameters
        (p_addr_width = p_addr_width)
        // Inputs
        (i_rd_clk = i_rd_clk,
         i_rd_rst_n = i_rd_rst_n,
         i_rd_en = i_rd_en,
         i_wr_grey_addr = o_wr_grey_addr);
        // Outputs
        (o_wr_ptr_sync = o_wr_ptr_sync);

    // Instantiate the read-to-write pointer sync module
    rtl_read_to_write_pointer_sync
        # Configuration parameters
        (p_addr_width = p_addr_width)
        // Inputs
        (i_wr_clk = i_wr_clk,
         i_wr_rst_n = i_wr_rst_n,
         i_wr_en = i_wr_en,
         i_rd_grey_addr = o_rd_grey_addr);
        // Outputs
        (o_rd_ptr_sync = o_rd_ptr_sync);

    // Instantiate the write pointer full module
    rtl_wptr_full
        # Configuration parameters
        (p_addr_width = p_addr_width)
        // Inputs
        (i_wr_clk = i_wr_clk,
         i_wr_rst_n = i_wr_rst_n,
         i_wr_en = i_wr_en,
         i_rd_ptr_sync = o_rd_ptr_sync);
        // Outputs
        (o_fifo_full = o_fifo_full,
         o_wr_bin_addr = o_wr_bin_addr,
         o_wr_grey_addr = o_wr_grey_addr);

    // Instantiate the read pointer empty module
    rtl_rptr_empty
        # Configuration parameters
        (p_addr_width = p_addr_width)
        // Inputs
        (i_rd_clk = i_rd_clk,
         i_rd_rst_n = i_rd_rst_n,
         i_rd_en = i_rd_en,
         i_wr_ptr_sync = o_wr_ptr_sync);
        // Outputs
        (o_fifo_empty = o_fifo_empty,
         o_rd_bin_addr = o_rd_bin_addr,
         o_rd_grey_addr = o_rd_grey_addr);

    // Connect internal nodes
    assign o_wr_bin_addr = r_wr_bin_addr[p_addr_width-1:0];
    assign o_rd_bin_addr = r_rd_bin_addr[p_addr_width-1:0];
endmodule