// Module instantiation for the FIFO
module async_fifo (
    // Clocks
    parameter p_data_width = 32,
    parameter p_addr_width = 16,

    // Input ports
    input  wire                i_wr_clk,       // Write clock
    input  wire                i_wr_rst_n,    // Write reset (active low)
    input  wire                i_wr_en,       // Write enable
    input  wire [p_data_width-1:0] i_wr_data,    // Write data
    input  wire                i_rd_clk,       // Read clock
    input  wire                i_rd_rst_n,    // Read reset (active low)
    input  wire                i_rd_en,       // Read enable
    input  wire [p_data_width-1:0] i_rd_data,    // Read data

    // Output ports
    output wire [p_data_width-1:0] o_rd_data,    // Read data
    output wire o_fifo_full,                    // FIFO full flag
    output wire o_fifo_empty,                   // FIFO empty flag

    // Synchronized pointers
    output reg  [p_addr_width:0] o_wr_ptr_sync,   // Write pointer
    output reg  [p_addr_width:0] o_rd_ptr_sync,   // Read pointer

    // Internal submodules
    fifo_memory,
    read_to_write_pointer_sync,
    write_to_read_pointer_sync,
    wptr_full
);

// Configuration for the FIFO
$sortname async_fifo

// Module instances configuration
$fifohandle fifo_memory: fifo_memory (
    .p_data_width(p_data_width),
    .p_addr_width(p_addr_width)
);

$fifohandle read_to_write_pointer_sync: read_to_write_pointer_sync (
    .p_addr_width(p_addr_width)
);

$fifohandle write_to_read_pointer_sync: write_to_read_pointer_sync (
    .p_addr_width(p_addr_width)
);

$fifohandle wptr_full: wptr_full (
    .p_addr_width(p_addr_width)
);

// Signal assignments
assign o_rd_data = fifo_memory.o_rd_data;

always @(posedge i_wr_clk or posedge i_rd_clk) begin
    // Synchronize the write pointer
    wptr_full.o_fifo_full = fifo_memory.o_fifo_full;
    
    // Update the FIFO full flag
    wptr_full.o_fifo_empty = fifo_memory.o_fifo_empty;
    
    // Update the write pointer
    wptr_full.o_wr_ptr_sync = fifo_memory.r_wr_ptr;
    
    // Update the read pointer
    wptr_full.o_rd_ptr_sync = fifo_memory.r_rd_ptr;
end

// Conversion between Gray-code and binary pointers
reg [p_addr_width:0] gray_address;
reg [p_addr_width:0] binary_address;

always @*begin
    gray_address = read_to_write_pointer_sync.o_wr_ptr_sync;
    binary_address = write_to_read_pointer_sync.o_rd_ptr_sync;
    
    // Update the FIFO write and read pointers
    fifo_memory.r_wr_ptr = binary_address;
    fifo_memory.r_rd_ptr = gray_address;
    
    // Invert the MSB for Gray code comparison
    wptr_full.r_wr_ptr_ff = (binary_address) ^ (binary_address >> 1);
    wptr_full.r_rd_ptr_ff = (gray_address) ^ (gray_address >> 1);
end