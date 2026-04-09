module rtl/async_fifo 
    #(
        parameter p_data_width = 32,
        parameter p_addr_width = 16
    ) (
        input  wire                i_wr_clk,
        input  wire                i_wr_clk_en,
        input  wire [p_data_width-1:0] i_wr_data,
        input  wire                i_wr_full,
        input  wire                i_rd_clk,
        input  wire                i_rd_clk_en,
        input  wire [p_data_width-1:0] i_rd_data,
        input  wire                i_rd_empty,
        output wire                o_fifo_full,
        output wire                o_fifo_empty
    );

    // Instantiate FIFO Memory
    fifo_memory
        #(
            parameter p_data_width = p_data_width,
            parameter p_addr_width = p_addr_width
        )
        (
            input  wire                i_wr_clk,
            input  wire                i_wr_clk_en,
            input  wire [p_data_width-1:0] i_wr_data,
            input  wire                i_wr_full,
            input  wire                i_rd_clk,
            input  wire                i_rd_clk_en,
            input  wire [p_data_width-1:0] i_rd_data,
            output wire [p_data_width-1:0] o_rd_data
        );

    // Instantiate Read to Write Pointer Sync
    read_to_write_pointer_sync
        #(
            parameter p_addr_width = p_addr_width
        )
        (
            input  wire                i_wr_clk,
            input  wire                i_wr_clk_en,
            input  wire [p_addr_width:0] i_rd_grey_addr,
            output reg  [p_addr_width:0] o_rd_ptr_sync
        );

    // Instantiate Write to Read Pointer Sync
    write_to_read_pointer_sync
        #(
            parameter p_addr_width = p_addr_width
        ) (
            input  wire                i_rd_clk,
            input  wire                i_rd_clk_en,
            input  wire [p_addr_width:0] i_wr_grey_addr,
            output reg  [p_addr_width:0] o_wr_ptr_sync
        );

    // Instantiate Wptr Full
    wptr_full
        #(
            parameter p_addr_width = p_addr_width
        ) (
            input  wire                i_wr_clk,
            input  wire                i_wr_clk_en,
            input  wire                i_wr_en,
            input  wire [p_addr_width:0] i_rd_ptr_sync,
            output reg                o_fifo_full,
            output wire [p_addr_width-1:0] o_wr_bin_addr,
            output reg  [p_addr_width:0] o_wr_grey_addr
        );

    // Instantiate Rptr Empty
    rptr_empty
        #(
            parameter p_addr_width = p_addr_width
        ) (
            input  wire                i_rd_clk,
            input  wire                i_rd_clk_en,
            input  wire [p_addr_width:0] i_wr_ptr_sync,
            output reg                o_fifo_empty,
            output wire [p_addr_width-1:0] o_rd_bin_addr,
            output reg  [p_addr_width:0] o_rd_grey_addr
        );
    
    // Signal assignments
    assign o_fifo_empty = o_rd_empty;
    assign o_fifo_full = o_fifo_full;
endmodule