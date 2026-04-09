rtl/search_binary_search_tree.sv
------------------------------------------------------------
module search_binary_search_tree #(
    parameter DATA_WIDTH = 32,         // Width of a single element
    parameter ARRAY_SIZE = 15          // Maximum number of elements in the BST
) (
    input clk,                         // Clock signal
    input reset,                       // Asynchronous active-high reset
    input reg start,                   // Start signal to initiate the search
    input reg [DATA_WIDTH-1:0] search_key, // Key to search for in the BST
    input reg [$clog2(ARRAY_SIZE):0] root, // Index of the root node (assumed to be 0)
    input reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys, // Packed array of node keys
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child, // Packed array of left child pointers
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child, // Packed array of right child pointers
    output reg [$clog2(ARRAY_SIZE):0] key_position, // In-order position of the found key (or null if not found)
    output reg complete_found,         // Asserted when search is complete and key found
    output reg search_invalid          // Asserted when search is invalid (e.g. empty tree or key not found)
);

    // FSM state parameters
    parameter S_IDLE             = 3'b000;
    parameter S_INIT             = 3'b001;
    parameter S_SEARCH_LEFT      = 3'b010;
    parameter S_SEARCH_LEFT_RIGHT= 3'b011;
    parameter S_COMPLETE_SEARCH  = 3'b100;

    // Current FSM state
    reg [2:0] search_state;

    // Variables for traversal and bookkeeping
    reg [$clog2(ARRAY_SIZE):0] position; // Counter for in-order visitation
    reg found;                           // Flag indicating if search_key was found

    // Flags for subtree completion (not used in this simplified version)
    reg left_done, right_done;

    // Stacks for managing traversal (packed arrays)
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_stack;
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1:0] right_stack; // Note: syntax adjusted for clarity

    // Stack pointers
    reg [$clog2(ARRAY_SIZE):0] sp_left;
    reg [$clog2(ARRAY_SIZE):0] sp_right;

    // Pointers for current nodes in left and right traversals
    reg [$clog2(ARRAY_SIZE):0] current_left_node;
    reg [$clog2(ARRAY_SIZE):0] current_right_node;

    // Output indices for traversal (not used in this simplified version)
    reg [$clog2(ARRAY_SIZE):0] left_output_index;
    reg [$clog2(ARRAY_SIZE):0] right_output_index;

    // Loop variable
    integer i;

    // For detecting an empty tree: count 3 cycles after start if tree is empty
    reg [1:0] empty_counter;

    // Note: A "null pointer" is represented by a value of all ones:
    //       {($clog2(ARRAY_SIZE)+1){1'b1}}

    // Main always block
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset FSM and all signals/variables
            search_state       <= S_IDLE;
            found               <= 0;
            position            <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            complete_found      <= 0;
            key_position        <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            left_output_index   <= 0;
            right_output_index  <= 0;
            sp_left             <= 0;
            sp_right            <= 0;
            left_done           <= 0;
            right_done          <= 0;
            empty_counter       <= 0;
            search_invalid      <= 0;
            // Clear stacks (each element is set to a null pointer)
            for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
                left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                right_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            end
        end else begin
            case (