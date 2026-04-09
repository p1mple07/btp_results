module spi_fsm (
    input  wire         i_clk,
    input  wire         i_rst_b,
    input  wire [15:0]  i_data_in,
    input  wire         i_enable,
    input  wire         i_fault,
    input  wire         i_clear,

    output reg          o_spi_cs_b,
    output reg          o_spi_clk,
    output reg          o_spi_data,
    output reg [4:0]    o_bits_left,
    output reg          o_done,
    output reg [1:0]    o_fsm_state
);

// ... implementation

endmodule
