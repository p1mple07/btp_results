// Inserting code for BUILD_TREE state
BUILD_TREE: begin
    // Check if we are at the end of the input data
    if (input_index == ARRAY_SIZE-1) begin
        // Assign the last input data as root if it's empty
        if (root == {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
            root <= temp_data;
            // Move to COMPLETE state
            top_state <= COMPLETE;
        end
    end else begin
        // Store the current input data
        temp_data <= data_in[input_index*DATA_WIDTH +: DATA_WIDTH];
        // Move to next index
        input_index <= input_index + 1;
    end
end

// Inserting code for SORT_TREE state
SORT_TREE: begin
    // Check if root is not NULL
    if (root != {($clog2(ARRAY_SIZE)+1){1'b1}) begin
        current_node <= root;
        sp <= 0; // Initialize stack pointer
        
        // Traverse the tree in-order
        while (sp != ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)) begin
            casez (current_state(sp))
                // Left child traversal
                left_child(sp) != {($clog2(ARRAY_SIZE)+1){1'b1}: begin
                    // Move to left child
                    current_node <= left_child(sp);
                    sp <= current_state(sp + 1);
                end
                
                // Process current node and store output
                output_index <= output_index + 1;
                sorted_out[output_index*DATA_WIDTH +: DATA_WIDTH] <= temp_data;
                output_index <= output_index + 1;
                
                // Check for right child
                right_child(sp) != {($clog2(ARRAY_SIZE)+1}{1'b1}: begin
                    // Move to right child
                    current_node <= right_child(sp);
                    sp <= current_state(sp + 1);
                end
            end
        end
    end else begin
        // If root is NULL, we are done
        done <= 1;
    end
end

// Helper function to get the state of the stack
function automatic integer current_state(integer sp);
    return sp / ($clog2(ARRAY_SIZE)+1);
end
