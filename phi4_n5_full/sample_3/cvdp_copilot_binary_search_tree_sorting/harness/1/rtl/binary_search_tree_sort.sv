rtl/binary_search_tree_sort.sv
------------------------------------------------------------
module binary_search_tree_sort #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 8
) (
    input clk,
    input reset,
    input [ARRAY_SIZE*DATA_WIDTH-1:0] data_in, // Input data to be sorted
    input start,
    output reg [ARRAY_SIZE*DATA_WIDTH-1:0] sorted_out, // Sorted output
    output reg done
);

    //-------------------------------------------------------------------------
    // Top-level FSM state definitions
    //-------------------------------------------------------------------------
    parameter IDLE = 2'b00, BUILD_TREE = 2'b01, SORT_TREE = 2'b10;

    //-------------------------------------------------------------------------
    // Local parameters for the BUILD_TREE FSM (4-bit encoding)
    //-------------------------------------------------------------------------
    localparam BUILD_INIT           = 4'b0000,
               BUILD_LOAD           = 4'b0001,
               BUILD_CHECK_ROOT     = 4'b0010,
               BUILD_SET_ROOT       = 4'b0011,
               BUILD_SET_CURRENT    = 4'b0100,
               BUILD_COMPARE        = 4'b0101,
               BUILD_LEFT           = 4'b0110,
               BUILD_INSERT_LEFT    = 4'b0111,
               BUILD_TRAVERSE_LEFT  = 4'b1000,
               BUILD_RIGHT          = 4'b1001,
               BUILD_INSERT_RIGHT   = 4'b1010,
               BUILD_TRAVERSE_RIGHT = 4'b1011,
               COMPLETE             = 4'b1100;
               
    //-------------------------------------------------------------------------
    // Local parameters for the SORT_TREE FSM (4-bit encoding)
    //-------------------------------------------------------------------------
    localparam S_INIT            = 4'b0000,
               S_TRAVERSE_LEFT   = 4'b0001,
               S_POP             = 4'b0010,
               S_CHECK_RIGHT     = 4'b0011,
               S_DONE            = 4'b0100;
               
    //-------------------------------------------------------------------------
    // Define NULL pointer for tree pointers
    //-------------------------------------------------------------------------
    localparam NULL_PTR = {($clog2(ARRAY_SIZE)+1){1'b1}};

    //-------------------------------------------------------------------------
    // Registers for FSM states
    //-------------------------------------------------------------------------
    reg [1:0] top_state;
    reg [3:0] build