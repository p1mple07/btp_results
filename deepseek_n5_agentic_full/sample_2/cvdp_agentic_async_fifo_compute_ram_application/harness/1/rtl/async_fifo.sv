rtl/async_fifo.sv

// This is auto-generated based on docs/fifo.md
module async_fifo (
    parameter p_data_width = 32,
    parameter p_addr_width = 16
);

    // Top-level ports
    input wire i_wr_clk;
    input wire i_wr_rst_n;
    input wire i_wr_en;
    input wire [p_data_width:0] i_wr_data;
    input wire i_wr_rst_n; // Assuming typo fixed here
    input wire i_wr_rst_n; // This seems incorrect, likely meant to duplicate i_wr_rst_n above
    Wait, there appears to be inconsistent port definitions. Let me fix that.

Corrected Port List:
input wire [p_data_width:0] i_wr_data;
output reg [p_data_width:0] o_fifo_full;
input wire i_rd_clk;
input wire i_rd_rst_n;
input wire i_rd_en;
input wire [p_data_width:0] i_rd_data;
output reg [p_data_width:0] o_rd_data;
output reg [p_addr_width:0] o_fifo_empty;

// Internal signals
reg [p_data_width:0] w_wr_bin_addr;
reg [p_addr_width:0] w_wr_grey_addr;
reg [p_addr_width:0] w_rd_ptr_sync;
reg [p_addr_width:0] w_rd_bin_addr;
reg [p_addr_width:0] w_rd_grey_addr;
reg [p_addr_width:0] w_wr_ptr_sync;
reg [p_addr_width:0] w_wr_grey_addr; // Duplicate, fixing later

Wait, I notice some duplication and inconsistencies. Let me reorganize the signals properly.

Proper Internal Signal Declaration:
wire [p_addr_width:0] w_wr_bin_addr,
wire [p_addr_width:0] w_wr_grey_addr,
reg [p_addr_width:0] w_rd_ptr_sync,
reg [p_addr_width:0] w_rd_bin_addr,
reg [p_addr_width:0] w_rd_grey_addr,
reg [p_addr_width:0] w_wr_ptr_sync,

// Submodule instantiations
 inst.read_to_write_pointer_sync #(p_addr_width) read_to_write_pointer_sync_inst (
    .o_rd_ptr_sync(w_rd_ptr_sync),
    .i_rd_grey_addr(w_rd_grey_addr),
    .i_wr_clk(i_wr_clk),
    .i_wr_rst_n(i_wr_rst_n)
);
 inst.write_to_read_pointer_sync #(p_addr_width) write_to_read_pointer_sync_inst (
    .i_rd_clk(i_rd_clk),
    .i_rd_rst_n(i_rd_rst_n),
    .i_wr_grey_addr(w_wr_grey_addr),
    .o_wr_ptr_sync(w_wr_ptr_sync)
);
 inst.wptr_full #(p_addr_width) wptr_full_inst (
    .i_wr_clk(i_wr_clk),
    .i_wr_rst_n(i_wr_rst_n),
    .i_wr_en(i_wr_en),
    .i_rd_ptr_sync(w_rd_ptr_sync),
    .o_fifo_full(o_fifo_full),
    .o_wr_bin_addr(w_wr_bin_addr),
    .o_wr_grey_addr(w_wr_grey_addr)
);
 inst.rptr_empty #(p_addr_width) rptr_empty_inst (
    .i_rd_clk(i_rd_clk),
    .i_rd_rst_n(i_rd_rst_n),
    .i_rd_en(i_rd_en),
    .i_wr_ptr_sync(w_wr_ptr_sync),
    .o_fifo_empty(o_fifo_empty),
    .o_rd_bin_addr(r_rd_bin_addr),
    .o_rd_grey_addr(r_rd_grey_addr)
);
 inst.fifo_memory #(p_data_width, p_addr_width) fifo_memory_inst (
    .i_wr_clk(i_wr_clk),
    .i_wr_clk_en(i_wr_en),
    .i_wr_addr(w_wr_bin_addr),
    .i_wr_data(i_wr_data),
    .i_wr_full(i_wr_full),
    .i_rd_clk(i_rd_clk),
    .i_rd_clk_en(i_rd_en),
    .i_rd_addr(r_rd_bin_addr),
    .o_rd_data(r_rd_data)
);

// Connect all ports according to the interface definition
i_wr_rst_n # Logic correction: Likely a typo in original port list
o_rd_data

// Note: The port declarations and connections need to match exactly what's defined in the specification
// Additional comments and implementation details can go here
// This generated code may require manual verification and testing against the specified behavior