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

    // Parameters for top‑level FSM states
    parameter IDLE = 2'b00,
          BUILD_TREE = 2'b01,
          SORT_TREE = 2'b10;

    // Insert code here to declare the parameters for the FSM states to be implemented

    // Registers for FSM states
    reg [1:0] top_state, build_state, sort_state;

    // BST representation
    reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys; // Array to store node keys
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child; // Left child pointers
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child; // Right child pointers
    reg [$clog2(ARRAY_SIZE):0] root; // Root node pointer
    reg [$clog2(ARRAY_SIZE):0] next_free_node; // Pointer to the next free node

    // Stack for in‑order traversal
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
                left_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}}; 
                right_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
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
                        left_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}}; 
                        right_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                        stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    end
                    if (start) begin
                        // Load input data into input array
                        top_state <= BUILD_TREE;
                        build_state <= INIT;
                    end
                end

                BUILD_TREE: begin
                    case (build_state)

                         // Insert code here to implement storing of the number to be inserted from the array,
                         // insertion of the root, and traversing the tree to find the correct position of the number to be inserted
                         based on the BST rules.

                    endcase
                end

                SORT_TREE: begin
                    case (sort_state)

                         // Insert code here to implement the sorting by handling the left child of the current_node,
                         // storing the output, and then further processing the right child of the current_node.

                    endcase
                end
            endcase
        end
    end
endmodule
