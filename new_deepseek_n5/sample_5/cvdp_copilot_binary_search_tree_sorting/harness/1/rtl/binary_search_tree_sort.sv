module binary_search_tree_sort #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 8
) (
    input clk,
    input reset,
    input reg [ARRAY_SIZE*DATA_WIDTH-1:0] data_in,
    input start,
    output reg [ARRAY_SIZE*DATA_WIDTH-1:0] sorted_out,
    output reg done
);

    // Parameters for top-level FSM states
    parameter IDLE = 2'b00, BUILD_TREE = 2'b01, SORT_TREE = 2'b10;

    // FSM states
    reg [1:0] top_state, build_state, sort_state;

    // BST representation
    reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys;
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child;
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child;
    reg [$clog2(ARRAY_SIZE):0] root;
    reg [$clog2(ARRAY_SIZE):0] next_free_node;
    reg [$clog2(ARRAY_SIZE):0] current_node;
    reg [$clog2(ARRAY_SIZE):0] input_index;
    reg [$clog2(ARRAY_SIZE):0] output_index;
    reg [DATA_WIDTH-1:0] temp_data;

    // Stack for traversal
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] stack;
    reg [$clog2(ARRAY_SIZE):0] sp;

    always @(posedge clk or posedge reset) begin
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
                        top_state <= BUILD_TREE;
                        build_state <= INIT;
                    end
                end

                BUILD_TREE: begin
                    case (build_state)
                        INIT: begin
                            temp_data <= data_in[input_index];
                            input_index <= input_index + 1;
                            
                            if (input_index > ARRAY_SIZE) begin
                                next_free_node <= root;
                                root <= next_free_node;
                                build_state <= COMPLETE;
                            end else begin
                                if (left_child[root] == 0) begin
                                    right_child[root] <= temp_data;
                                    current_node <= right_child[root];
                                    build_state <= INSERT;
                                end else begin
                                    current_node <= left_child[root];
                                    while (left_child[current_node] != 0) begin
                                        current_node <= left_child[current_node];
                                    end
                                    if (left_child[current_node] == 0) begin
                                        left_child[current_node] <= temp_data;
                                        build_state <= INSERT;
                                    else begin
                                        temp_data <= right_child[current_node];
                                        current_node <= right_child[current_node];
                                    end
                                    end
                                end
                            end
                        end
                end

                SORT_TREE: begin
                    case (sort_state)
                        S_INIT: begin
                            stack <= root;
                            sp <= 0;
                            output_index <= 0;
                            
                            while (sp < $clog2(ARRAY_SIZE)) begin
                                current_node <= stack[sp];
                                sp <= sp + 1;
                                
                                if (left_child[current_node] == 0) begin
                                    stack[sp] <= left_child[current_node];
                                    sp <= sp + 1;
                                    temp_data <= current_node;
                                    sorted_out[output_index] <= temp_data;
                                    output_index <= output_index + DATA_WIDTH;
                                    sp <= sp - 1;
                                    if (sp >= $clog2(ARRAY_SIZE)) begin
                                        stack <= stack[0:sp];
                                        sp <= 0;
                                    end
                                    continue;
                                end
                                
                                if (right_child[current_node] == 0) begin
                                    stack[sp] <= right_child[current_node];
                                    sp <= sp + 1;
                                    temp_data <= current_node;
                                    sorted_out[output_index] <= temp_data;
                                    output_index <= output_index + DATA_WIDTH;
                                    sp <= sp - 1;
                                    if (sp >= $clog2(ARRAY_SIZE)) begin
                                        stack <= stack[0:sp];
                                        sp <= 0;
                                    end
                                    continue;
                                end
                                
                                temp_data <= current_node;
                                sorted_out[output_index] <= temp_data;
                                output_index <= output_index + DATA_WIDTH;
                                sp <= sp - 1;
                                if (sp >= $clog2(ARRAY_SIZE)) begin
                                    stack <= stack[0:sp];
                                    sp <= 0;
                                end
                            end
                            
                            done <= 1;
                            top_state <= IDLE;
                        end
                end
            endcase
        end
    end
endmodule