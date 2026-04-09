// Inside the BUILD_TREE state
case (build_state)
    INIT: begin
        if (input_index < ARRAY_SIZE) begin
            temp_data <= data_in[input_index*DATA_WIDTH +: DATA_WIDTH];
            current_node <= root;
            next_free_node <= current_node;
            input_index <= input_index + 1;
            build_state <= BUILD_TREE;
        end else begin
            // Tree construction complete
            top_state <= SORT_TREE;
            sort_state <= S_INIT;
        end
    end

// Inside the SORT_TREE state
case (sort_state)
    S_INIT: begin
        // Initialize output array with zeros
        output_index <= 0;
        
        // Start sorting by traversing left subtree
        if (current_node != root) begin
            left_child <= current_node;
            current_node <= left_child;
            sp <= next_free_node;
            sort_state <= L_TRAVERSAL;
        end else begin
            output_index <= 0;
            top_state <= IDLE;
        end
    end

    L_TRAVERSAL: begin
        // Traverse left subtree until leaf node
        if (left_child != root) begin
            if (right_child[left_child] == 1'b1) begin
                // Right child exists, move to right subtree
                current_node <= right_child[left_child];
                sp <= next_free_node;
                sort_state <= L_TRAVERSAL;
            end else begin
                // Left child is leaf, store output and move to next element
                sorted_out[output_index*DATA_WIDTH +: DATA_WIDTH] <= temp_data;
                output_index <= output_index + 1;
                top_state <= IDLE;
            end
        end else begin
            // Left child is NULL, move to next element
            output_index <= output_index + 1;
            top_state <= IDLE;
        end
    end

    // When all elements are processed, set done high
    ALL_ELEMENTS_PROCESSED: begin
        done <= 1'b1;
        top_state <= IDLE;
    end
endcase
