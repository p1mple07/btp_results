module delete_node_binary_search_tree (
    input clk,
    input reset,
    input reg start,
    input reg [DATA_WIDTH-1:0] delete_key,
    input reg [$clog2(ARRAY_SIZE):0] root,
    input reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child,
    output reg [$clog2(ARRAY_SIZE):0] key_position,
    output reg complete_deletion,
    output reg delete_invalid,
    output reg modified_keys,
    output reg modified_left_child,
    output reg modified_right_child
);

// reset logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        search_state <= S_IDLE;
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

        // clear stacks
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            right_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
        end
    end else begin
        // main FSM
        case (search_state)
            S_IDLE: begin
                // reset intermediate variables
                for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
                    left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    right_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                end
                complete_found <= 0;
                search_invalid <= 0;
                position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};

                if (start) begin
                    left_output_index <= 0;
                    right_output_index <= 0;
                    sp_left <= 0;
                    sp_right <= 0;
                    left_done <= 0;
                    right_done <= 0;
                    found <= 0;
                    search_state <= S_INIT;
                end
            end

            S_INIT: begin
                if (root != {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
                    if (search_key == keys[root*DATA_WIDTH +: DATA_WIDTH]) begin
                        found <= 1;
                        if (left_child[0*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] == {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
                            position <= 0;
                            search_state <= S_COMPLETE_SEARCH;
                        end else begin
                            search_state <= S_SEARCH_LEFT;
                            current_left_node <= left_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                        end
                    end else if (keys[0*DATA_WIDTH +: DATA_WIDTH] > search_key) begin
                        search_state <= S_SEARCH_LEFT;
                        current_left_node <= left_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    end else begin
                        current_left_node <= left_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                        current_right_node <= right_child[root*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                        search_state <= S_SEARCH_LEFT_RIGHT;
                    end
                end else begin
                    search_state <= S_COMPLETE_SEARCH;
                end
            end

            S_SEARCH_LEFT: begin
                // traverse left
                if (current_left_node != {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
                    left_stack[sp_left*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= current_left_node;
                    sp_left <= sp_left + 1;
                    current_left_node <= left_child[current_left_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                end else if (sp_left > 0) begin
                    sp_left <= sp_left - 1;
                    current_left_node <= left_stack[(sp_left - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    left_output_index <= left_output_index + 1;
                    current_left_node <= right_child[left_stack[(sp_left - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)]*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                end else begin
                    left_done <= 1;
                end

                if (!found) begin
                    if (!right_done && current_right_node != {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
                        right_stack[sp_right*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= current_right_node;
                        sp_right <= sp_right + 1;
                        current_right_node <= left_child[current_right_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    end else if (!right_done && sp_right > 0) begin
                        sp_right <= sp_right - 1;
                        current_right_node <= right_stack[(sp_right - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                        if (search_key == keys[right_stack[(sp_right - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)]*DATA_WIDTH +: DATA_WIDTH]) begin
                            found <= 1;
                        end
                        right_output_index <= right_output_index + 1;
                        current_right_node <= right_child[right_stack[(sp_right - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)]*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    end else if (!right_done) begin
                        right_done <= 1;
                    end
                end
            end

            S_SEARCH_LEFT_RIGHT: begin
                if (!left_done && current_left_node != {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
                    left_stack[sp_left*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= current_left_node;
                    sp_left <= sp_left + 1;
                    current_left_node <= left_child[current_left_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                end else if (!left_done && sp_left > 0) begin
                    sp_left <= sp_left - 1;
                    current_left_node <= left_stack[(sp_left - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    left_output_index <= left_output_index + 1;
                    current_left_node <= right_child[left_stack[(sp_left - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)]*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                end else if (!left_done) begin
                    left_done <= 1;
                end

                if (!found) begin
                    if (!right_done && current_right_node != {($clog2(ARRAY_SIZE)+1){1'b1}}) begin
                        right_stack[sp_right*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= current_right_node;
                        sp_right <= sp_right + 1;
                        current_right_node <= left_child[current_right_node*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    end else if (!right_done && sp_right > 0) begin
                        sp_right <= sp_right - 1;
                        current_right_node <= right_stack[(sp_right - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                        if (search_key == keys[right_stack[(sp_right - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)]*DATA_WIDTH +: DATA_WIDTH]) begin
                            found <= 1;
                        end
                        right_output_index <= right_output_index + 1;
                        current_right_node <= right_child[right_stack[(sp_right - 1)*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)]*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)];
                    end else if (!right_done) begin
                        right_done <= 1;
                    end
                end
            end

            S_COMPLETE_SEARCH: begin
                if (!found) begin
                    complete_found <= 0;
                    key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    search_invalid <= 1;
                end else begin
                    complete_found <= 1;
                    key_position <= position;
                    search_invalid <= 0;
                end
                search_state <= S_IDLE;
            end

            default: begin
                search_state <= S_IDLE;
            end
        endcase
    end

endmodule
