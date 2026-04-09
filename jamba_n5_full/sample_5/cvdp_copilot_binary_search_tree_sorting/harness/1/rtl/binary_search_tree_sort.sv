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
    reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys; // Node keys
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child; // Left child pointers
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child; // Right child pointers
    reg [$clog2(ARRAY_SIZE):0] root; // Root node address
    reg [$clog2(ARRAY_SIZE):0] next_free_node; // Next free node pointer

    // Stack for in‑order traversal
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] stack; // Stack entries
    reg [$clog2(ARRAY_SIZE):0] sp; // Stack pointer

    // Working registers
    reg [$clog2(ARRAY_SIZE):0] current_node; // Current node being processed
    reg [$clog2(ARRAY_SIZE):0] input_index; // Data index
    reg [$clog2(ARRAY_SIZE):0] output_index; // Output index
    reg [DATA_WIDTH-1:0] temp_data; // Temporary data

    // Initial state setup
    integer i;

    @(posedge clk or posedge reset) begin
        if (reset) begin
            top_state <= IDLE;
            build_state <= INIT;
            sort_state <= S_INIT;

            root <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            next_free_node <= 0;
            sp <= 0;
            input_index <= 0;
            output_index <= 0;
            done <= 0;

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
                    root <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    next_free_node <= 0;
                    sp <= 0;
                    for (i = 0; i < ARRAY_SIZE+1; i = i + 1) begin
                        keys[i*DATA_WIDTH +: DATA_WIDTH] <= 0;
                        left_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                        right_child[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                        stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    end
                    if (start) begin
                        // Load input data into the BST
                        top_state <= BUILD_TREE;
                        build_state <= INIT;
                    end
                end

                BUILD_TREE: begin
                    case (build_state)
                        // Insert each new element into the tree
                        if (root == {$clog2(ARRAY_SIZE)+1){1'b1}}) begin
                            // Tree is empty – insert as root
                            root <= temp_data;
                            next_free_node <= 0;
                            temp_data <= 0;
                        end else begin
                            // Find the leaf where the new node belongs
                            if (temp_data < keys[root*DATA_WIDTH +: DATA_WIDTH]) begin
                                keys[left_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1))] = temp_data;
                                left_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] = right_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                                right_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] = root;
                                root = temp_data;
                            end else begin
                                keys[right_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1))] = temp_data;
                                right_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] = left_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                                left_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] = root;
                                root = temp_data;
                            end
                            next_free_node <= 0;
                        end
                    endcase
                end

                SORT_TREE: begin
                    case (sort_state)
                        // Perform in‑order traversal and output sorted values
                        SORT_TREE: begin
                            while (current_node != 0 && stack != 0) begin
                                if (current_node.left_child[current_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] == 0) begin
                                    output_index <= output_index + 1;
                                    temp_data <= keys[current_node*DATA_WIDTH +: DATA_WIDTH];
                                end else begin
                                    current_node = current_node.left_child[current_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                                end
                            end
                            if (current_node != 0) begin
                                output_index <= output_index + 1;
                                temp_data <= keys[current_node*DATA_WIDTH +: DATA_WIDTH];
                            end
                        end
                    endcase
                end
            endcase
        end
    end
endmodule
