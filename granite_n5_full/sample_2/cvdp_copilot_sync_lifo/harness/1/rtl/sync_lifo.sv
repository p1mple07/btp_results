module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
) (
    input  logic                  clock,
    input  logic                  reset,
    input  logic                  write_en,
    input  logic                  read_en,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  empty,
    output logic                  full
);
    // Implement the synchronous FIFO logic here
    //...
endmodule