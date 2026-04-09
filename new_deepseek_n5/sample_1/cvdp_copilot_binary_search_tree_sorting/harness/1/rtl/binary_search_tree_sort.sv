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

    // Stack for traversal
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] stack;
    reg [$clog2(ARRAY_SIZE):0] sp;

    // Working registers
    reg [$clog2(ARRAY_SIZE):0] current_node;
    reg [$clog2(ARRAY_SIZE):0] input_index;
    reg [$clog2(ARRAY_SIZE):0] output_index;
    reg [DATA_WIDTH-1:0] temp_data;

    // Initialize all variables
    integer i;

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

                    for (i = 0; i < ARRAY_SIZE + 1; i = i + 1) begin
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
                                current_node <= root;
                                build_state <= BUILD完;
                                top_state <= IDLE;
                            end else begin
                                if (left_child[root] == 0) begin
                                    root <= {left_child[root], temp_data};
                                    left_child[root] <= temp_data;
                                    build_state <= INSERT;
                                end else begin
                                    current_node <= left_child[root];
                                    while (current_node != 0 && right_child[current_node] == 0) begin
                                        current_node <= right_child[current_node];
                                        next_free_node <= current_node;
                                    end
                                    if (current_node == 0) begin
                                        next_free_node <= current_node;
                                        current_node <= next_free_node;
                                        build_state <= INSERT;
                                    else begin
                                        temp_data <= right_child[current_node];
                                        right_child[current_node] <= temp_data;
                                        build_state <= INSERT;
                                    end
                                end
                            end
                        endcase
                    endcase
                end

                BUILD完: begin
                    top_state <= IDLE;
                    build_state <= INIT;
                end
            endcase
        end
    end
endmodule