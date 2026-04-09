rtl/binary_search_tree_sort.sv
------------------------------------------------------------
module binary_search_tree_sort #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 8
) (
    input         clk,
    input         reset,
    input  [ARRAY_SIZE*DATA_WIDTH-1:0] data_in,  // Input data to be sorted
    input         start,
    output reg [ARRAY_SIZE*DATA_WIDTH-1:0] sorted_out, // Sorted output
    output reg    done
);

    //-------------------------------------------------------------------------
    // Top-level FSM state parameters
    //-------------------------------------------------------------------------
    parameter IDLE      = 2'b00,
              BUILD_TREE = 2'b01,
              SORT_TREE  = 2'b10;

    //-------------------------------------------------------------------------
    // BUILD_TREE FSM state parameters (4-bit states)
    //-------------------------------------------------------------------------
    parameter BUILD_INIT          = 4'b0000,
              BUILD_LOAD           = 4'b0001,
              BUILD_INSERT_ROOT    = 4'b0010,
              BUILD_SET_CURRENT    = 4'b0011,
              BUILD_COMPARE        = 4'b0100,
              BUILD_LEFT           = 4'b0101,
              BUILD_LEFT_GO        = 4'b0110,
              BUILD_RIGHT          = 4'b0111,
              BUILD_RIGHT_GO       = 4'b1000,
              BUILD_INCREMENT      = 4'b1001,
              BUILD_COMPLETE       = 4'b1010;

    //-------------------------------------------------------------------------
    // SORT_TREE FSM state parameters (3-bit states)
    //-------------------------------------------------------------------------
    parameter