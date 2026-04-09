module binary_search_tree_sort #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 8
) (
    input clk,
    input reset,
    input reg [ARRAY_SIZE*DATA_WIDTH-1:0] data_in, // Input data to be sorted
    input start,
    output reg [ARRAY_SIZE*DATA_WIDTH-1:0] sorted_out, // Sorted output
    output reg done
);

    // Parameters for top-level FSM states
    parameter IDLE = 2'b00, BUILD_TREE = 2'b01, SORT_TREE = 2'b10;

    // Registers for FSM states
    reg [1:0] top_state, build_state, sort_state;

    // BST representation
    reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys; // Array to store node keys
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child; // Left child pointers
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child; // Right child pointers
    reg [$clog2(ARRAY_SIZE):0] root; // Root node pointer
    reg [$clog2(ARRAY_SIZE):0] next_free_node; // Pointer to the next free node

    // Stack for in-order traversal
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] stack; // Stack for traversal
    reg [$clog2(ARRAY_SIZE):0] sp; // Stack pointer  

    // Working registers
    reg [$clog2(ARRAY_SIZE):0] current_node; // Current node being processed
    reg [$clog2(ARRAY_SIZE):0] input_index; // Index for input data
    reg [$clog2(ARRAY_SIZE):0] output_index; // Index for output data
    reg [DATA_WIDTH-1:0] temp_data; // Temporary data register

    // Initialize all variables
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all states and variables
            top_state <= IDLE;
            build_state <= INIT;
            sort_state <= S_INIT;
            
            root <= {($clog2(ARRAY_SIZE)+1){1'b1}}; ; // Null pointer
            next_free_node <= 0;
            sp <= 0;
            input_index <= 0;
            output_index <= 0;
            done <= 0;

            // Clear tree arrays
            for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
                keys[i*DATA_WIDTH +: DATA_WIDTH] <= 0;
                left_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}}; 
                right_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}};
                stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}};
            end

        end else begin
            case (top_state)
                IDLE: begin
                    done <= 0;
                    input_index <= 0;
                    output_index <= 0; 
                    root <= {($clog2(ARRAY_SIZE)+1){1'b1}}; ; // Null pointer
                    next_free_node <= 0;
                    sp <= 0;
                    for (i = 0; i < ARRAY_SIZE+1; i = i + 1) begin
                        keys[i*DATA_WIDTH +: DATA_WIDTH] <= 0;
                        left_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}}; 
                        right_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}};
                        stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}};
                    end
                    if (start) begin
                        // Load input data into input array
                        top_state <= BUILD_TREE;
                        build_state <= INIT;
                    end
                end

                BUILD_TREE: begin
                    case (build_state)
                        INIT: begin
                            // Load the next number from input array
                            input_index <= ARRAY_SIZE;
                            build_state <= LOAD_NEXT;
                        end
                        LOAD_NEXT: begin
                            // If input_index is 0, tree is built
                            if (input_index == 0) begin
                                top_state <= COMPLETE;
                                build_state <= COMPLETE_INIT;
                            end else begin
                                build_state <= TRAVERSAL;
                                input_index <= input_index - 1;
                            end
                        end
                        COMPLETE_INIT: begin
                            // Store the number in the tree
                            temp_data <= data_in[input_index*DATA_WIDTH +: DATA_WIDTH - 1];
                            build_state <= INSERT;
                        end
                        INSERT: begin
                            // Check if root is empty
                            if (root == 0) begin
                                root <= temp_data;
                                build_state <= INSERT_COMPLETE;
                            end else begin
                                current_node <= root;
                                build_state <= TRAVERSAL;
                            end
                        end
                        INSERT_COMPLETE: begin
                            // Increment next_free_node
                            next_free_node <= next_free_node + 1;
                            build_state <= LOAD_NEXT;
                        end
                    endcase
                end
                TRAVERSAL: begin
                    // Traverse the tree to find the correct position
                    case (current_node)
                        {($clog2(ARRAY_SIZE)+1){1'b1}}: begin // Root node
                            build_state <= TRAVERSAL;
                        end
                        {($clog2(ARRAY_SIZE)+1){1'b1}}: begin // Empty left child
                            build_state <= INSERT_LEFT;
                        end
                        {($clog2(ARRAY_SIZE)+1){1'b1}}: begin // Empty right child
                            build_state <= INSERT_RIGHT;
                        end
                        _: begin // Any other child
                            build_state <= TRAVERSAL;
                        end
                    endcase
                end
                INSERT_LEFT: begin
                    // Insert into left child
                    left_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)] <= temp_data;
                    next_free_node <= next_free_node + 1;
                    build_state <= TRAVERSAL;
                end
                INSERT_RIGHT: begin
                    // Insert into right child
                    right_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)] <= temp_data;
                    next_free_node <= next_free_node + 1;
                    build_state <= TRAVERSAL;
                end
            endcase
        end

        case (sort_state)
            S_INIT: begin
                // Initialization for sorting
                sp <= 0;
                current_node <= root;
                output_index <= 0;
                sort_state <= INIT_SORT;
            end
            INIT_SORT: begin
                // Initialize output array
                sorted_out <= {0};
                sort_state <= READY_SORT;
            end
            READY_SORT: begin
                // Ready to start sorting
                done <= 0;
                sort_state <= TRAVERSAL_SORT;
            end
            TRAVERSAL_SORT: begin
                // Traverse the tree in-order
                case (sp)
                    0: begin
                        // Traverse left subtree
                        current_node <= left_child[sp +: ($clog2(ARRAY_SIZE)+1)];
                        sp <= sp + 1;
                    end
                    1: begin
                        // Process current node
                        output_index <= output_index + 1;
                        sorted_out[output_index*DATA_WIDTH +: DATA_WIDTH - 1] <= temp_data;
                        done <= 1;
                        sort_state <= READY_SORT;
                    end
                    2: begin
                        // Traverse right subtree
                        current_node <= right_child[sp +: ($clog2(ARRAY_SIZE)+1)];
                        sp <= 0;
                    end
                end
            endcase
        end
    end
endmodule
