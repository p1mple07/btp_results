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
    
    // FSM states
    parameter S_IDLE = 3'b000,
              S_INIT = 3'b001,
              S_SEARCH_LEFT = 3'b010,
              S_SEARCH_LEFT_RIGHT = 3'b011,
              S_COMPLETE_SEARCH = 3'b100;
    
    // FSM state register
    reg [2:0] search_state;
    
    // Variables for traversal
    reg [$clog2(ARRAY_SIZE):0] position;
    reg found;
    
    // Stack for traversal
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_stack;
    reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_stack;
    reg [$clog2(ARRAY_SIZE):0] sp_left;
    reg [$clog2(ARRAY_SIZE):0] sp_right;
    
    // Pointers for current nodes
    reg [$clog2(ARRAY_SIZE):0] current_left_node;
    reg [$clog2(ARRAY_SIZE):0] current_right_node;
    
    // Output indices for traversal
    reg [$clog2(ARRAY_SIZE):0] left_output_index;
    reg [$clog2(ARRAY_SIZE):0] right_output_index;
    
    // Loop index
    integer i;
    
    // Always block
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all states and variables
            search_state <= S_IDLE;
            found <= 0;
            position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            complete_found <= 0;
            key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            left_output_index <= 0;
            right_output_index <= 0;
            sp_left <= 0;
            sp_right <= 0;
            current_left_node <= 0;
            current_right_node <= 0;
            left_done <= 0;
            right_done <= 0;
            search_state <= S_IDLE;
            search_invalid <= 0;
        end else begin
            if (start) begin
                search_state <= S_INIT;
                found <= 0;
                position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                left_output_index <= 0;
                right_output_index <= 0;
                sp_left <= 0;
                sp_right <= 0;
                current_left_node <= 0;
                current_right_node <= 0;
                left_done <= 0;
                right_done <= 0;
            end
        end
    end
    
    // Case for initialization
    case (search_state)
        S_IDLE: begin
            for (i = 0; i < ARRAY_SIZE+1; i = i + 1) begin
                left_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                right_stack[i*($clog2(ARRAY_SIZE)+1) +: ($clog2(ARRAY_SIZE)+1)] <= {($clog2(ARRAY_SIZE)+1){1'b1}};
            end
            complete_found <= 0;
            search_invalid <= 0;
            
            if (start) begin
                search_state <= S_INIT;
                found <= 0;
                position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                left_output_index <= 0;
                right_output_index <= 0;
                sp_left <= 0;
                sp_right <= 0;
                current_left_node <= 0;
                current_right_node <= 0;
                left_done <= 0;
                right_done <= 0;
            end
        end
        
        S_INIT: begin
            if (root == 0) begin
                search_invalid <= 1;
                key_position <= {($clog2(ARRAY_SIZE)+1){1'b1}};
                complete_found <= 0;
                search_state <= S_IDLE;
                continue;
            end
            if (search_key < root) begin
                search_state <= S_SEARCH_LEFT;
            elsif (search_key > root) begin
                search_state <= S_SEARCH_LEFT_RIGHT;
            else begin
                found <= 1;
                key_position <= root;
                complete_found <= 1;
                search_state <= S_COMPLETE_SEARCH;
            end
        end
        
        S_SEARCH_LEFT: begin
            if (left_stack[sp_left*($clog2(ARRAY_SIZE)+1) + left_output_index] == 1) begin
                left_output_index <= left_output_index + 1;
                current_left_node <= left_stack[sp_left*($clog2(ARRAY_SIZE)+1) + left_output_index];
                sp_left <= sp_left + 1;
                
                if (left_child[current_left_node] == 1) begin
                    left_output_index <= left_output_index - 1;
                    left_done <= 1;
                    left_output_index <= left_output_index - 1;
                    current_left_node <= left_child[current_left_node];
                    sp_left <= left_output_index;
                end
            end
            search_state <= S_SEARCH_LEFT;
        end
        
        S_SEARCH_LEFT_RIGHT: begin
            if (left_stack[sp_left*($clog2(ARRAY_SIZE)+1) + left_output_index] == 1) begin
                left_output_index <= left_output_index + 1;
                current_left_node <= left_stack[sp_left*($clog2(ARRAY_SIZE)+1) + left_output_index];
                sp_left <= sp_left + 1;
            end
            if (right_stack[sp_right*($clog2(ARRAY_SIZE)+1) + right_output_index] == 1) begin
                right_output_index <= right_output_index + 1;
                current_right_node <= right_stack[sp_right*($clog2(ARRAY_SIZE)+1) + right_output_index];
                sp_right <= sp_right + 1;
            end
            search_state <= S_SEARCH_LEFT_RIGHT;
        end
        
        S_COMPLETE_SEARCH: begin
            if (found) begin
                complete_found <= 1;
                key_position <= key_position[sp_left*($clog2(ARRAY_SIZE)+1) + ($clog2(ARRAY_SIZE)+1)];
                search_state <= S_IDLE;
            end
            search_invalid <= 0;
            sp_left <= 0;
            sp_right <= 0;
            left_output_index <= 0;
            right_output_index <= 0;
            left_done <= 0;
            right_done <= 0;
        end
        
        default: begin
            search_state <= S_IDLE;
        end
    endcase
endmodule