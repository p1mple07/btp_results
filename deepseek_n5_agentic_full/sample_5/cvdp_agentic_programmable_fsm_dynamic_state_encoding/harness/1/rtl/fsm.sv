module fsm (
    input clk,
    input reset,
    input [3:0] input_signal,
    input [63:0] config_state_map_flat,
    input [127:0] config_transition_map_flat,
    output reg [7:0] current_state,
    output reg error_flag,
    output reg [7:0] operation_result
);

    // New Regs for dynamic encoding
    reg [7:0] state;
    reg [7:0] encoded_state;
    reg [7:0] dynamic_encoded_state;

    // Mapping configurations
    wire [7:0] encoded_state = config_state_map_flat[state]; // Use config_state_map_flat for dynamic state encoding
    wire [7:0] dynamic_encoded_state = encoded_state ^ input_signal; // Apply dynamic transformation

    // Rest of the state transition logic
    reg [7:0] next_state;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            encoded_state <= 0;
            dynamic_encoded_state <= 0;
        end else begin
            state <= next_state;
            encoded_state <= config_transition_map_flat[(state << 4) + input_signal]; 
            dynamic_encoded_state <= encoded_state ^ input_signal;
            
            if (encoded_state > 8'h7) begin
                error_flag = 1;
                encoded_state <= 0;
            end else begin
                error_flag = 0;
            end
        end
    end

    always @(*) begin
        case (state)
            8'h0: operation_result = config_state_map_flat[encoded_state] + input_signal;
            8'h1: operation_result = config_state_map_flat[encoded_state] - input_signal;
            8'h2: operation_result = config_state_map_flat[encoded_state] & input_signal;
            8'h3: operation_result = config_state_map_flat[encoded_state] | input_signal;
            default: operation_result = 8'hFF;
        endcase
    end

endmodule