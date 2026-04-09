module binary_search_tree_sort #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 8
) (
    input         clk,
    input         reset,
    input  [ARRAY_SIZE*DATA_WIDTH-1:0] data_in, // Input data to be sorted
    input         start,
    output reg [ARRAY_SIZE*DATA_WIDTH-1:0] sorted_out, // Sorted output
    output reg    done
);

    // Top-level FSM states
    parameter TOP_IDLE  = 2'b00,
              TOP_BUILD = 2'b01,
              TOP_SORT  = 2'b10;

    // BUILD_TREE sub-FSM states (3-bit encoding)
    parameter BUILD_INIT      = 3'b000,
              BUILD_LOAD       = 3'b001,
              BUILD_ROOT       = 3'b010,
              BUILD_TRAVERSE   = 3'b011,
              BUILD_COMPLETE   = 3'b100;

    // SORT_TREE sub-FSM states (3-bit encoding)
    parameter S_INIT          = 3'b000,
              S_TRAVEL_LEFT   = 3'b001,
              S_OUTPUT        = 3'b010,
              S_TRAVEL_RIGHT  = 3'b011,
              S_DONE          = 3'b100; // Not strictly used

    // FSM state registers
    reg [1:0] top_state;
    reg [2:0] build_state;
    reg [2:0] sort_state;

    // BST representation using arrays
    // Each node is represented by an index into the arrays.
    reg [DATA_WIDTH-1:0] keys [0:ARRAY_SIZE-1];
    reg [$clog2(ARRAY_SIZE):0] left_child [0:ARRAY_SIZE-1];
    reg [$clog2(ARRAY_SIZE):0] right_child [0:ARRAY_SIZE-1];
    reg [$clog2(ARRAY_SIZE):0] root;          // Root node pointer (index)
    reg [$clog2(ARRAY_SIZE):0] next_free_node; // Next free node index

    // Define a NULL pointer as all ones
    localparam NULL_PTR = {($clog2(ARRAY_SIZE)+1){1'b1}};

    // Stack for in-order traversal
    reg [$clog2(ARRAY_SIZE):0] stack [0:ARRAY_SIZE-1];
    reg [$clog2(ARRAY_SIZE):0] sp; // Stack pointer

    // Working registers
    reg [$clog2(ARRAY_SIZE):0] current_node; // Current node being processed
    reg [$clog2(ARRAY_SIZE):0] input_index;   // Index for input data
    reg [$clog2(ARRAY_SIZE):0] output_index;  // Index for output data
    reg [DATA_WIDTH-1:0] temp_data;           // Temporary data register

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all states and variables
            top_state      <= TOP_IDLE;
            build_state    <= BUILD_INIT;
            sort_state     <= S_INIT;
            
            root           <= NULL_PTR;
            next_free_node <= 0;
            sp             <= 0;
            input_index    <= 0;
            output_index   <= 0;
            done           <= 0;

            // Clear BST arrays
            for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
                keys[i]         <= 0;
                left_child[i]   <= NULL_PTR;
                right_child[i]  <= NULL_PTR;
                stack[i]        <= NULL_PTR;
            end
        end else begin
            case (top_state)
                TOP_IDLE: begin
                    done          <= 0;
                    input_index   <= 0;
                    output_index  <= 0;
                    root          <= NULL_PTR;
                    next_free_node<= 0;
                    sp            <= 0;
                    // Clear BST arrays
                    for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
                        keys[i]         <= 0;
                        left_child[i]   <= NULL_PTR;
                        right_child[i]  <= NULL_PTR;
                        stack[i]        <= NULL_PTR;
                    end
                    if (start) begin
                        top_state   <= TOP_BUILD;
                        build_state <= BUILD_INIT;
                    end
                end

                TOP_BUILD: begin
                    case (build_state)
                        BUILD_INIT: begin
                            // Check if all input elements have been processed
                            if (input_index >= ARRAY_SIZE) begin
                                build_state <= BUILD_COMPLETE;
                            end else begin
                                build_state <= BUILD_LOAD;
                            end
                        end

                        BUILD_LOAD: begin
                            // Load the next data element from data_in into temp_data
                            temp_data <= data_in[input_index*DATA_WIDTH +: DATA_WIDTH];
                            input_index <= input_index + 1;
                            // After loading, decide next action
                            build_state <= BUILD_INIT;
                        end

                        BUILD_ROOT: begin
                            // Tree is empty; insert as root
                            root          <= next_free_node;
                            keys[next_free_node]  <= temp_data;
                            left_child[next_free_node]   <= NULL_PTR;
                            right_child[next_free_node]  <= NULL_PTR;
                            next_free_node <= next_free_node + 1;
                            build_state   <= BUILD_INIT;
                        end

                        BUILD_TRAVERSE: begin
                            // Traverse the tree to find the correct insertion point
                            if (temp_data < keys[current_node]) begin
                                // Go left
                                if (left_child[current_node] == NULL_PTR) begin
                                    left_child[current_node] <= next_free_node;
                                    keys[next_free_node]  <= temp_data;
                                    left_child[next_free_node]   <= NULL_PTR;
                                    right_child[next_free_node]  <= NULL_PTR;
                                    next_free_node <= next_free_node + 1;
                                    build_state   <= BUILD_INIT;
                                end else begin
                                    current_node <= left_child[current_node];
                                    build_state  <= BUILD_TRAVERSE;
                                end
                            end else begin
                                // For equal or greater values, go right
                                if (right_child[current_node] == NULL_PTR) begin
                                    right_child[current_node] <= next_free_node;
                                    keys[next_free_node]  <= temp_data;
                                    left_child[next_free_node]   <= NULL_PTR;
                                    right_child[next_free_node]  <= NULL_PTR;
                                    next_free_node <= next_free_node + 1;
                                    build_state   <= BUILD_INIT;
                                end else begin
                                    current_node <= right_child[current_node];
                                    build_state  <= BUILD_TRAVERSE;
                                end
                            end
                        end

                        BUILD_COMPLETE: begin
                            // All input elements have been inserted; complete tree construction.
                            top_state <= TOP_SORT;
                            sort_state <= S_INIT;
                        end

                    endcase
                end

                TOP_SORT: begin
                    case (sort_state)
                        S_INIT: begin
                            // Initialize in-order traversal.
                            if (root == NULL_PTR) begin
                                // Nothing to sort.
                                done          <= 1;
                                top_state     <= TOP_IDLE;
                                sort_state    <= S_INIT;
                            end else begin
                                // Push the root node onto the stack.
                                stack[0]      <= root;
                                sp            <= 1;
                                current_node  <= left_child[root];
                                sort_state    <= S_TRAVEL_LEFT;
                            end
                        end

                        S_TRAVEL_LEFT: begin
                            if (current_node != NULL_PTR) begin
                                // Push the current node and move to its left child.
                                stack[sp]      <= current_node;
                                sp             <= sp + 1;
                                current_node   <= left_child[current_node];
                                sort_state     <= S_TRAVEL_LEFT;
                            end else begin
                                sort_state <= S_OUTPUT;
                            end
                        end

                        S_OUTPUT: begin
                            if (sp != 0) begin
                                // Pop the top node from the stack.
                                current_node <= stack[sp-1];
                                sp           <= sp - 1;
                                // Store the node's key into the sorted output array.
                                sorted_out[output_index*DATA_WIDTH +: DATA_WIDTH] <= keys[current_node];
                                output_index <= output_index + 1;
                                // Move to the right subtree.
                                current_node <= right_child[current_node];
                                if (current_node != NULL_PTR) begin
                                    sort_state <= S_TRAVEL_LEFT;
                                end else begin
                                    sort_state <= S_OUTPUT;
                                end
                            end else begin
                                // No more nodes to process; sorting complete.
                                done          <= 1;
                                top_state     <= TOP_IDLE;
                                sort_state    <= S_INIT;
                            end
                        end

                    endcase
                end

            endcase
        end
    end
endmodule