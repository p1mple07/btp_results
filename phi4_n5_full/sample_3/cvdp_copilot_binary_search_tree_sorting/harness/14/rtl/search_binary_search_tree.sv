rtl/search_binary_search_tree.sv
module search_binary_search_tree #(
    parameter DATA_WIDTH = 32,         // Width of a single element
    parameter ARRAY_SIZE = 15          // Maximum number of elements in the BST
) (
    input  clk,                        // Clock signal
    input  reset,                      // Asynchronous active-high reset
    input  start,                      // Start signal to initiate the search
    input  [DATA_WIDTH-1:0] search_key, // Key to search for in the BST
    input  [$clog2(ARRAY_SIZE):0] root, // Index of the root node (assumed 0)
    input  [ARRAY_SIZE*DATA_WIDTH-1:0] keys, // Packed array of node keys
    input  [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child, // Packed array of left child pointers
    input  [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child, // Packed array of right child pointers
    output reg [$clog2(ARRAY_SIZE):0] key_position, // Position of the found key (or invalid)
    output reg complete_found,         // Asserted when search is complete and key is found
    output reg search_invalid          // Asserted when search is invalid (key not found or empty tree)
);

    // FSM state parameters
    parameter S_IDLE                   = 3'b000,
              S_INIT                   = 3'b001,
              S_SEARCH_LEFT            = 3'b010,
              S_SEARCH_LEFT_RIGHT      = 3'b011,
              S_COMPLETE_SEARCH        = 3'b100;
    
    // Current state of the FSM
    reg [2:0] search_state;
    
    // Variables to manage traversal
    reg [$clog2(ARRAY_SIZE):0] position; // Current in-order position counter
    reg found;                           // Flag to indicate key found (not used explicitly here)
    
    reg left_done, right_done;           // Completion flags for left/right traversals
    
    // Stacks for managing traversal (each entry is a pointer width)
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_stack;  
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_stack; 
    reg [$clog2(ARRAY_SIZE):0] sp_left;         // Stack pointer for left subtree
    reg [$clog2(ARRAY_SIZE):0] sp_right;        // Stack pointer for right subtree
    
    // Pointers for the current nodes in left and right subtrees
    reg [$clog2(ARRAY_SIZE):0] current_left_node;  
    reg [$clog2(ARRAY_SIZE):0] current_right_node; 
    
    // (Unused in this implementation)
    reg [$clog2(ARRAY_SIZE):0] left_output_index;  
    reg [$clog2(ARRAY_SIZE):0] right_output_index; 
    
    // Loop index
    integer i;
    
    // Counter used for empty tree detection (wait 3 clock cycles after start)
    reg [1:0] empty_counter;
    
    // Sequential always block: triggered on rising edge of clk or posedge reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset FSM state and all traversal/control signals
            search_state       <= S_IDLE;
            found               <= 0;
            position            <= {($clog2(ARRAY_SIZE)+1){1'b1}}; // Invalid position (all ones)
            complete_found      <= 0;
            key_position        <= {($clog2(ARRAY_SIZE)+1){1'b1}}; // Invalid key position
            left_output_index   <= 0;
            right_output_index  <= 0;
            sp_left             <= 0;
            sp_right            <= 0;
            left_done           <= 0;
            right_done          <= 0;
            search_state        <= S_IDLE;
            search_invalid      <= 0;
            empty_counter       <= 0;
            
            // Clear the stacks (initialize with null pointers: all ones)
            for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
                left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY