// BUILD_TREE FSM
BUILD_TREE: begin
    if (input_index == ARRAY_SIZE) begin
        done <= 1;
        top_state <= IDLE;
    end else begin
        // Load input data into input array
        temp_data <= data_in[input_index*DATA_WIDTH +: DATA_WIDTH];
        input_index <= input_index + 1;

        // Check if root is empty and assign temp_data as root
        if (root == {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
            root <= temp_data;
            build_state <= INIT;
        end else begin
            // Compare temp_data with current_node
            case (root)
                temp_data > current_node) begin
                    // Move to the right subtree
                    current_node <= right_child[current_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    build_state <= INIT;
                end else if (temp_data < current_node) begin
                    // Move to the left subtree
                    current_node <= left_child[current_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    build_state <= INIT;
                end else begin
                    // Current_node is a leaf, insert temp_data
                    left_child[current_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= temp_data;
                    build_state <= NO_CHILD;
                end
            endcase
        end
    end
end

// SORT_TREE FSM
SORT_TREE: begin
    case (sort_state)
        S_INIT: begin
            if (root != {($clog2(ARRAY_SIZE)+1){1'b1}) begin
                // Initialize current_node to root
                current_node <= root;
                sp <= 0;
                output_index <= 0;
            end else begin
                sp <= 1; // Mark that we have an output pending
            end
        end

        NO_CHILD: begin
            if (sp == 0) begin
                // Pop from stack and store output
                output_index <= output_index + 1;
                temp_data <= stack[output_index*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                sp <= 0;
                // Move to the next node
                current_node <= stack[output_index*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                sort_state <= LEFT_CHILD;
            end else begin
                sp <= 1; // Output pending
            end
        end

        LEFT_CHILD: begin
            // Traverse left subtree
            case (current_node)
                temp_data > current_node) begin
                    current_node <= left_child[current_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    sort_state <= LEFT_CHILD;
                end else if (temp_data < current_node) begin
                    // No more left children, insert output
                    sorted_out[output_index*DATA_WIDTH +: DATA_WIDTH] <= temp_data;
                    output_index <= output_index + 1;
                    done <= 1;
                    sort_state <= DONE;
                end
            end
        end

        RIGHT_CHILD: begin
            // Traverse right subtree
            case (current_node)
                temp_data > current_node) begin
                    // Move to the right subtree
                    current_node <= right_child[current_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    sort_state <= RIGHT_CHILD;
                end else if (temp_data < current_node) begin
                    // No more right children, insert output
                    sorted_out[output_index*DATA_WIDTH +: DATA_WIDTH] <= temp_data;
                    output_index <= output_index + 1;
                    done <= 1;
                    sort_state <= DONE;
                end
            end
        end
    endcase
end
