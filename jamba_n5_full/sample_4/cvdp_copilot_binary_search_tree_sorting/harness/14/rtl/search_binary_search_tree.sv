module search_binary_search_tree #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 15
) (
    input clk,
    input reset,
    input reg start,
    input reg [DATA_WIDTH-1:0] search_key,
    input reg [$clog2(ARRAY_SIZE):0] root,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] keys,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child,
    output reg [$clog2(ARRAY_SIZE):0] key_position,
    output reg complete_found,
    output reg search_invalid
);

reg [2:0] search_state;
reg found;
reg left_done, right_done;
reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_stack, right_stack;
reg [$clog2(ARRAY_SIZE):0] sp_left, sp_right;

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

        for (int i = 0; i < ARRAY_SIZE; i = i + 1) begin
            left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            right_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
        end
    end else begin
        case (search_state)
            S_IDLE: begin
                search_state <= S_INIT;
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
                search_state <= S_INIT;
            end

            S_INIT: begin
                if (start) begin
                    left_output_index <= 0;
                    right_output_index <= 0;
                    sp_left <= 0;
                    sp_right <= 0;
                    left_done <= 0;
                    right_done <= 0;
                    found <= 0;
                    position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                end
                if (search_key == root) begin
                    search_state <= S_COMPLETE_SEARCH;
                    complete_found <= 1;
                    key_position <= 0;
                end else if (search_key < root) begin
                    search_state <= S_SEARCH_LEFT;
                end else begin
                    search_state <= S_SEARCH_LEFT_RIGHT;
                end
            end

            S_SEARCH_LEFT: begin
                if (left_child[root*($clog2(ARRAY_SIZE)+1)+left_done]) begin
                    root = left_child[root*($clog2(ARRAY_SIZE)+1)+left_done];
                    left_done <= 1;
                end
            end

            S_SEARCH_LEFT_RIGHT: begin
                if (right_child[root*($clog2(ARRAY_SIZE)+1)+right_done]) begin
                    root = right_child[root*($clog2(ARRAY_SIZE)+1)+right_done];
                    right_done <= 1;
                end
            end

            S_COMPLETE_SEARCH: begin
                if (found) begin
                    key_position <= 0;
                    complete_found <= 1;
                    search_invalid <= 0;
                end else begin
                    key_position <= 1'b1;
                    complete_found <= 0;
                    search_invalid <= 1;
                end
                search_state <= S_IDLE;
            end

            default: begin
                search_state <= S_IDLE;
            end
        endcase
    end
endmodule
