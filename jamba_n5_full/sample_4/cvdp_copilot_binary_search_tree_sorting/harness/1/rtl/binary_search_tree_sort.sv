when (build_state == 1) // 1 means building tree
begin
    case (build_state)
        0: begin // Not applicable
            pass;
        end
        1: begin
            // Start building tree
            // We need to read input_index, and insert each element.
            // But we can assume we have an array of data_in and we process sequentially.
            // In simulation, we can just assign.
            if (input_index < ARRAY_SIZE) begin
                // Insert input_index into BST
                temp_data = data_in[input_index];
                // Insert into BST logic
                // Assume we have a function insert; but we can just set.
                keys[next_free_node*DATA_WIDTH +: DATA_WIDTH] = temp_data;
                left_child[next_free_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] = next_free_node*($clog2(ARRAY_SIZE)+1);
                right_child[next_free_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] = next_free_node*($clog2(ARRAY_SIZE)+1) + DATA_WIDTH;
                next_free_node = next_free_node + 1;
                input_index = input_index + 1;
            end else begin
                // End of array
                top_state <= SORT_TREE;
                build_state <= COMPLETE;
            end
        end
        2: begin
            // Done
            top_state <= SORT_TREE;
            build_state <= COMPLETE;
        end
    endcase
end
