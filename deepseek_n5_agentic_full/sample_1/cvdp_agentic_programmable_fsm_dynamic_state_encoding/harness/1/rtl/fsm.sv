module fsm (
    input clk,
    input reset,
    input [3:0] input_signal,
    input [63:0] config_state_map_flat,
    input [127:0] config_transition_map_flat,
    output reg [7:0] state,
    output reg error_flag,
    output reg [7:0] operation_result
);

    
    reg [7:0] state;
    reg [7:0] next_state;
    
    // New variables for dynamic encoding
    wire [7:0] encoded_state;    // Encoded state representation
    wire [7:0] dynamic_encoded_state;  // Dynamic encoded state
    
    // Transformations for encoded states
    encoded_state = state + input_signal;        // Example transformation
    dynamic_encoded_state = encoded_state ^ (input_signal >> 2);  // Another possible transformation
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= 0;
            next_state    <= 0;
        end else
            state         <= next_state;
    end

    always @(*) begin
        integer idx;
        idx = (state << 4) + input_signal; 
        next_state = config_transition_map_flat[(idx * 8) + 7];
        
        if (next_state > 8'h7) begin
            error_flag = 1;
            next_state = 0; 
        end else begin
            error_flag = 0;
        end

        case (state)
            8'h0: operation_result = config_state_map_flat[0] + input_signal;
            8'h1: operation_result = config_state_map_flat[1] - input_signal;
            8'h2: operation_result = config_state_map_flat[2] & input_signal;
            8'h3: operation_result = config_state_map_flat[3] | input_signal;
            default: operation_result = 8'hFF; 
        endcase
    end

endmodule