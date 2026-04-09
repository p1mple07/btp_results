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

// -------------------------------------------------------------
// 1. Reset on reset signal
// -------------------------------------------------------------
always @(posedge clk or posedge reset) begin
    if (reset) begin
        search_state <= S_IDLE;
        found     <= 0;
        position   <= {($clog2(ARRAY_SIZE)+1){1'b1}};
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
    end else begin

        // 2. Initialise the FSM state
        case (search_state)
            S_IDLE: begin
                // Wait for the 'start' signal
                if (start) begin
                    search_state <= S_INIT;
                end
            end

            S_INIT: begin
                // Compare the search key with the root node
                if (search_key == root) begin
                    // Found the key at the root – we need to find its position
                    search_state <= S_SEARCH_LEFT;
                end else if (search_key < root) begin
                    search_state <= S_SEARCH_LEFT;
                end else begin
                    search_state <= S_SEARCH_LEFT_RIGHT;
                end
            end

            S_SEARCH_LEFT: begin
                // Go left – no need to check right children
                search_state <= S_SEARCH_LEFT;
            end

            S_SEARCH_LEFT_RIGHT: begin
                // Go left, then right if needed
                if (search_key < root) begin
                    search_state <= S_SEARCH_LEFT;
                else begin
                    search_state <= S_SEARCH_LEFT_RIGHT;
                end
            end

            S_COMPLETE_SEARCH: begin
                // Check if the search key was found
                if (found) begin
                    complete_found <= 1;
                    key_position <= position;
                    search_invalid <= 0;
                end else begin
                    complete_found <= 0;
                    key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                    search_invalid <= 1;
                end
            end

            default: begin
                search_state <= S_IDLE;
            end
        endcase
    end
endmodule
