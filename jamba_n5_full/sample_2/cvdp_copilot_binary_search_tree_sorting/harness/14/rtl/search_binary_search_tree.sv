module search_binary_search_tree #(
    parameter DATA_WIDTH = 32,
    parameter ARRAY_SIZE = 15
) (
    input clk,
    input reset,
    input reg start,
    input reg [DATA_WIDTH-1:0] search_key,
    input reg [$clog2(ARRAY_SIZE):0] root,
    input reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child,
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child,
    output reg [$clog2(ARRAY_SIZE):0] key_position,
    output reg complete_found,
    output reg search_invalid
);

reg [2:0] search_state;
reg [DATA_WIDTH-1:0] position;
reg found;
reg left_done, right_done;
reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_stack;
reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_stack;
reg [$clog2(ARRAY_SIZE):0] sp_left, sp_right;
reg found;

initial begin
    search_state <= S_IDLE;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        search_state <= S_IDLE;
        found <= 0;
        position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
        complete_found <= 0;
        key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
        left_done <= 0;
        right_done <= 0;
        sp_left <= 0;
        sp_right <= 0;
        left_stack <= {};
        right_stack <= {};
        search_invalid <= 0;
    end else begin
        case (search_state)
            S_IDLE: begin
                if (start) begin
                    search_state <= S_INIT;
                end
                else begin
                    search_state <= S_IDLE;
                end
            end
            S_INIT: begin
                if (search_key == root) begin
                    state <= S_COMPLETE_SEARCH;
                end else if (search_key < root) begin
                    state <= S_SEARCH_LEFT;
                end else begin
                    state <= S_SEARCH_LEFT_RIGHT;
                end
            end
            S_SEARCH_LEFT: begin
                if (left_child[current_left_node]) begin
                    current_left_node <= left_child[current_left_node];
                    left_stack[sp_left] <= current_left_node;
                end else begin
                    state <= S_COMPLETE_SEARCH;
                end
            end
            S_SEARCH_LEFT_RIGHT: begin
                if (right_child[current_right_node]) begin
                    current_right_node <= right_child[current_right_node];
                    right_stack[sp_right] <= current_right_node;
                end else begin
                    state <= S_COMPLETE_SEARCH;
                end
            end
            S_COMPLETE_SEARCH: begin
                if (found)
                    complete_found <= 1;
                else
                    complete_found <= 0;
                search_invalid <= 0;
                key_position <= 0;
                search_state <= S_IDLE;
            end
            default: state <= S_IDLE;
        endcase
    end
end

endmodule
