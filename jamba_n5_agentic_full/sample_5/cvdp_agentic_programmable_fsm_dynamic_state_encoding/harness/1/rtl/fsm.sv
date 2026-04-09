`timescale 1ns/1ps
module fsm (
    input clk,
    input reset,
    input [3:0] input_signal,
    input [63:0] config_state_map_flat,
    input [127:0] config_transition_map_flat,
    output reg [7:0] current_state,
    output reg error_flag,
    output reg [7:0] operation_result,
    output reg encoded_state,
    output reg dynamic_encoded_state
);

    reg [7:0] state;
    reg [7:0] next_state;

    // Mapping from state index to internal state value
    localparam constant int state_index_to_value(int idx) = 8'h0 + idx;

    // Initialise state from the flat config
    assign state = state_index_to_value(state);

    // Compute the encoded internal state
    assign encoded_state = config_state_map_flat[state];

    // Derive dynamic encoded state (optional transformation)
    assign dynamic_encoded_state = encoded_state ^ input_signal;

    // Always block for clocked state and next_state
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= 0;
            current_state <= 0;
            error_flag    <= 0;
            encoded_state <= 0;
            dynamic_encoded_state <= 0;
        end else begin
            state         <= next_state;
            next_state = config_transition_map_flat[(idx * 8) + 7 -: 8];

            if (next_state > 8'h7) begin
                error_flag = 1;
                next_state = 0;
            end else begin
                error_flag = 0;
            end

            case (state)
                8'h0: operation_result = config_state_map0 + input_signal;
                8'h1: operation_result = config_state_map1 - input_signal;
                8'h2: operation_result = config_state_map2 & input_signal;
                8'h3: operation_result = config_state_map3 | input_signal;
                default: operation_result = 8'hFF;
            endcase
        end
    end

endmodule
