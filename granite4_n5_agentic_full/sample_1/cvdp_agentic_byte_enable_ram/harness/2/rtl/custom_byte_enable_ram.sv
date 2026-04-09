module custom_byte_enable_ram #(
    parameter int XLEN = 32,
    parameter int LINES = 8192
) (
    input bit clk,
    input bit [ADDR_WIDTH-1:0] addr_a,
    input bit en_a,
    input bit [XLEN-1:0] be_a,
    input bit [XLEN-1:0] data_in_a,
    output bit [XLEN-1:0] data_out_a
) ;

// Add your implementation here.

endmodule