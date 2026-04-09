module search_binary_search_tree #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 15
) (
    input clk,
    input reset,
    input reg start,
    input reg [DATA_WIDTH-1:0] search_key,
    input reg [$clog2(ARRAY_SIZE):0] root,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] keys,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child,
    output reg [$clog2(ARRAY_SIZE):0] key_position,
    output reg complete_found,
    output reg search_invalid
);

    // FSM states
    parameter S_IDLE = 3'b000,
          S_INIT = 3'b001,
          S_SEARCH_LEFT = 3'b010,
          S_SEARCH_LEFT_RIGHT = 3'b011,
          S_COMPLETE_SEARCH = 3'b100;

    // registers
    reg [2:0] search_state;
    reg found;
    reg position;
    reg found_flag;
    reg left_done, right_done;

    // ...

endmodule
