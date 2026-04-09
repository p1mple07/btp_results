// ... (previous code context)

// Build Tree FSM: Insert elements into the BST
BUILD_TREE: begin
    case (build_state)
        INIT: begin
            if (input_index < ARRAY_SIZE) begin
                // Store input data into input array
                temp_data <= data_in[input_index*DATA_WIDTH +: DATA_WIDTH];
                input_index <= input_index + 1;

                // If root is null, assign temp_data as root
                if (root == {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
                    root <= temp_data;
                    current_node <= root;
                end else begin
                    // Traverse the tree to find the correct insertion point
                    left_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1}{1'b1}};
                    next_free_node <= next_free_node + 1;
                    current_node <= left_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)];
                    if (current_node == root) begin
                        // Reached the end of the left subtree, insert temp_data as right child
                        left_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)] <= temp_data;
                        next_free_node <= next_free_node + 1;
                    end
                end
            end else begin
                // All elements have been inserted, transition to COMPLETE state
                build_state <= COMPLETE;
            end
        end
    endcase
end

// SORT_TREE FSM: Perform in-order traversal of the BST to sort the array
SORT_TREE: begin
    case (sort_state)
        S_INIT: begin
            // Initialize current node and stack
            current_node <= root;
            sp <= 0;
            output_index <= 0;

            // Traverse the left subtree
            while (current_node != {($clog2(ARRAY_SIZE)+1}{1'b1}) begin
                left_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)] <= current_node;
                next_free_node <= next_free_node + 1;
                current_node <= left_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)];
            end

            // Store output and process right subtree
            output_index <= output_index + 1;
            temp_data <= current_node;

            // Traverse the right subtree
            while (next_free_node > 0) begin
                right_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)] <= current_node;
                next_free_node <= next_free_node - 1;
                current_node <= right_child[next_free_node +: ($clog2(ARRAY_SIZE)+1)];
                output_index <= output_index + 1;
                temp_data <= current_node;
            end

            // Sorting completed, set done high
            done <= 1;
        end
    endcase
end

// ... (following code context)
