module search_binary_search_tree #(
    parameter DATA_WIDTH = 32,         // Width of the data (of a single element)
    parameter ARRAY_SIZE = 15          // Maximum number of elements in the BST
) (

    input clk,                         // Clock signal
    input reset,                       // Reset signal
    input reg start,                   // Start signal to initiate the search
    input reg [DATA_WIDTH-1:0] search_key, // Key to search in the BST
    input reg [$clog2(ARRAY_SIZE):0] root, // Root node of the BST
    input reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys, // Node keys in the BST
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child, // Left child pointers
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child, // Right child pointers
    output reg [$clog2(ARRAY_SIZE):0] key_position, // Position of the found key
    output reg complete_found,         // Signal indicating search completion
    output reg search_invalid          // Signal indicating invalid search
);
                                                                                                                                        
    // Parameters for FSM states
    parameter S_IDLE = 3'b000,                 // Idle state
              S_INIT = 3'b001,                 // Initialization state
              S_SEARCH_LEFT = 3'b010,          // Search in left subtree
              S_SEARCH_LEFT_RIGHT = 3'b011,    // Search in both left and right subtrees
              S_COMPLETE_SEARCH = 3'b100;      // Search completion state
   
    // Registers to store the current FSM state
    reg [2:0] search_state;

    // Variables to manage traversal
    reg [$clog2(ARRAY_SIZE):0] position;       // Position of the current node
    reg found;                                 // Indicates if the key is found

    reg left_done, right_done;                 // Flags to indicate completion of left and right subtree traversals

    // Stacks for managing traversal of left and right subtrees
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_stack;  // Stack for left subtree traversal
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_stack; // Stack for right subtree traversal
    reg [$clog2(ARRAY_SIZE):0] sp_left;         // Stack pointer for left subtree
    reg [$clog2(ARRAY_SIZE):0] sp_right;        // Stack pointer for right subtree

    // Pointers for the current nodes in left and right subtrees
    reg [$clog2(ARRAY_SIZE):0] current_left_node;  // Current node in the left subtree
    reg [$clog2(ARRAY_SIZE):0] current_right_node; // Current node in the right subtree

    // Output indices for traversal
    reg [$clog2(ARRAY_SIZE):0] left_output_index;  // Output index for left subtree
    reg [$clog2(ARRAY_SIZE):0] right_output_index; // Output index for right subtree

    // Integer for loop iterations
    integer i;

    // Always block triggered on the rising edge of the clock or reset signal
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all states and variables
            search_state <= S_IDLE;  // Set state to IDLE
            found <= 0;              // Reset found flag
            position <= {($clog2(ARRAY_SIZE)+1){1'b1}}; // Invalid position
            complete_found <= 0;     // Reset complete_found signal
            key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}}; // Invalid key position
            left_output_index <= 0;  // Reset left output index
            right_output_index <= 0; // Reset right output index
            sp_left <= 0;            // Reset left stack pointer
            sp_right <= 0;           // Reset right stack pointer
            left_done <= 0;          // Reset left_done flag
            right_done <= 0;         // Reset right_done flag
            search_state <= S_IDLE;  // Set state to IDLE
            search_invalid <= 0;        // Set invalid_key to 0
            
            // Clear the stacks
            for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
                left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                right_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            end

        end else begin
            // Main FSM logic
            case (search_state)
                S_IDLE: begin
                    // Reset intermediate variables
                    for (i = 0; i < ARRAY_SIZE+1; i = i + 1) begin
                        left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                        right_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}};
                    end
                    found <= 0;
                    position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    complete_found <= 0;
                    key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    left_output_index <= 0;
                    right_output_index <= 0;
                    sp_left <= 0;
                    sp_right <= 0;
                    left_done <= 0;
                    right_done <= 0;
                    search_state <= S_IDLE;
                    search_invalid <= 0;

                    if (start) begin
                        // Start the search
                        left_output_index <= 0;
                        right_output_index <= 0;
                        sp_left <= 0;
                        sp_right <= 0;
                        left_done <= 0;
                        right_done <= 0;
                        found <= 0;
                        position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                        key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                        search_state <= S_INIT; // Move to INIT state
                    end
                end

                S_INIT: begin
                    // Determine initial traversal direction based on search_key and root
                    case (search_key[DATA_WIDTH-1:0] == root[DATA_WIDTH-1:0])
                        '1: begin // search_key == root_key
                            // Found the search_key, initialize position and found flag
                            position <= 0;
                            found <= 1;
                            key_position <= position;
                            search_state <= S_COMPLETE_SEARCH;
                        end
                        '0: begin // search_key != root_key
                            search_state <= S_SEARCH_LEFT;
                        end
                    end
                end

                S_SEARCH_LEFT: begin
                    // Traverse left subtree if search_key < root_key
                    if (left_child[sp_left*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1]) != 0) begin
                        // Push current node to stack and move to the left child
                        current_left_node <= left_child[sp_left*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1]];
                        sp_left <= sp_left + 1;
                        search_state <= S_SEARCH_LEFT;
                    end else begin
                        // No more left nodes, set left_done flag
                        left_done <= 1;
                        search_state <= S_COMPLETE_SEARCH;
                    end
                end

                S_SEARCH_LEFT_RIGHT: begin
                    // Traverse both subtrees if search_key > root_key
                    if (right_child[sp_right*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1]) != 0) begin
                        // Push current node to stack and move to the right child
                        current_right_node <= right_child[sp_right*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1]];
                        sp_right <= sp_right + 1;
                        search_state <= S_SEARCH_LEFT_RIGHT;
                    end else begin
                        // No more right nodes, set right_done flag
                        right_done <= 1;
                        search_state <= S_COMPLETE_SEARCH;
                    end
                end

                S_COMPLETE_SEARCH: begin
                    // Check if the search_key was found
                    if (found) begin
                        // Key found, set key_position and complete_found
                        key_position <= position;
                        complete_found <= 1;
                    end else begin
                        // Key not found, set search_invalid
                        search_invalid <= 1;
                    end
                    // Reset position and found for next search
                    position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    found <= 0;
                end

                default: begin
                    search_state <= S_IDLE; // Default to IDLE state
                end
            endcase
        end
    end

endmodule
