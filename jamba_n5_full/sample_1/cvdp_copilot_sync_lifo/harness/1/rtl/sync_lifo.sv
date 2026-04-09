module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input wire clock,
    input wire reset,
    input wire write_en,
    input wire read_en,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [ADDR_WIDTH-1:0] address, // for read? but we don't use address, only for write? Actually, we don't need address. The read_en and write_en are the signals.
    output reg empty,
    output reg full,
    output reg [DATA_WIDTH-1:0] data_out
);
