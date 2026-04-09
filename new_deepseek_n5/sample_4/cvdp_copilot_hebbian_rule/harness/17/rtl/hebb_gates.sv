module hebbian_rule(
    input clock,
    input rst,
    input start,
    input [3:0] a,
    input [3:0] b,
    input [1:0] gate_select,
    output [3:0] w1,
    output [3:0] w2,
    output [3:0] bias,
    output [3:0] present_state,
    output next_state
);

    // State variable
    reg state = 0;

    // State-specific registers
    reg [3:0] x1, x2;
    reg [3:0] temp_w1, temp_w2;
    reg [3:0] temp_bias;
    reg [3:0] target;
    reg [3:0] delta_w1, delta_w2, delta_b;

    // Initialize weights and bias to zero
    always @* begin
        x1 = a;
        x2 = b;
        temp_w1 = 0;
        temp_w2 = 0;
        temp_bias = 0;
    end

    // State transitions and logic
    case(state)
        // State 0: Reset state
        0: 
            if (rst == 1 && start == 1) begin
                state = 0;
                present_state = 0;
                next_state = 0;
                // Initialize weights and bias
                w1 = 0;
                w2 = 0;
                bias = 0;
                // Capture inputs
                x1 = a;
                x2 = b;
                // Compute target based on gate select
                case(gate_select)
                    00: target = a & b;
                    01: target = a | b;
                    10: target = ~(a & b);
                    11: target = ~(a | b);
                endcase
                // Calculate deltas
                delta_w1 = x1 & target;
                delta_w2 = x2 & target;
                delta_b = target;
                // Update weights and bias
                w1 = w1 + delta_w1;
                w2 = w2 + delta_w2;
                bias = bias + delta_b;
                // Prepare for next iteration
                state = 1;
                present_state = 0;
                next_state = 0;
            end
            // Negative edge transition
            default: state = 1;
    end

        // State 1: Capture inputs
        1: 
            // Compute deltas
            delta_w1 = x1 & target;
            delta_w2 = x2 & target;
            delta_b = target;
            // Update weights and bias
            temp_w1 = w1 + delta_w1;
            temp_w2 = w2 + delta_w2;
            temp_bias = bias + delta_b;
            // Transition to next state
            next_state = 2;
            present_state = 1;
            // Negative edge transition
            default: next_state = 2;

        // State 2: Assign targets
        2: 
            // Transition to next state
            next_state = 3;
            present_state = 2;
            // Negative edge transition
            default: next_state = 3;

        // State 3: Compute deltas
        3: 
            // Transition to next state
            next_state = 4;
            present_state = 3;
            // Negative edge transition
            default: next_state = 4;

        // State 4: Update weights and bias
        4: 
            // Update weights and bias
            w1 = temp_w1;
            w2 = temp_w2;
            bias = temp_bias;
            // Transition to next state
            next_state = 5;
            present_state = 4;
            // Negative edge transition
            default: next_state = 5;

        // State 5: Loop through iterations
        5: 
            // Transition to next state
            next_state = 0;
            present_state = 5;
            // Negative edge transition
            default: next_state = 0;

    endcase

    // Output the updated weights and bias
    output_w1: w1 = temp_w1;
    output_w2: w2 = temp_w2;
    output_bias: bias = temp_bias;

endmodule