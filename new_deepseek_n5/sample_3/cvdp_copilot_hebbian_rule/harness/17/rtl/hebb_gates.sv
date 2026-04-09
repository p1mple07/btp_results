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
    output [3:0] next_state
);

    // State variable
    reg state = 0;
    reg [3:0] x1, x2;
    reg [3:0] target;
    reg [3:0] delta_w1, delta_w2, delta_b;
    reg iteration = 0;

    // State transition logic
    always @(posedge clock or active_edge rst) begin
        if (rst) begin
            // Initialize weights and bias to zero
            w1 = 4'b0000;
            w2 = 4'b0000;
            bias = 4'b0000;
            present_state = 4'b0000;
            next_state = 4'b0000;
            x1 = 4'b0000;
            x2 = 4'b0000;
            target = 4'b0000;
            iteration = 0;
        elsif (start) begin
            // Capture inputs
            x1 = a;
            x2 = b;
            
            // Determine target based on gate_select
            case (gate_select)
                2'b00: target = x1 & x2;
                2'b01: target = x1 | x2;
                2'b10: target = ~ (x1 & x2);
                2'b11: target = ~ (x1 | x2);
            endcase
            
            // Calculate deltas
            delta_w1 = x1 & target;
            delta_w2 = x2 & target;
            delta_b = target;
            
            // Update weights and bias
            w1 = w1 + delta_w1;
            w2 = w2 + delta_w2;
            bias = bias + delta_b;
            
            // Transition to next state
            present_state = state;
            next_state = 8;
            
            // Increment iteration counter
            iteration = iteration + 1;
        end
    end

    // FSM state transitions
    case (state)
        0: begin
            // Capture inputs
            x1 = a;
            x2 = b;
            
            // Determine target based on gate_select
            target = (gate_select == 2'b00) ? (x1 & x2) :
                    (gate_select == 2'b01) ? (x1 | x2) :
                    (gate_select == 2'b10) ? (~ (x1 & x2)) :
                    (~ (x1 | x2));
            
            // Calculate deltas
            delta_w1 = x1 & target;
            delta_w2 = x2 & target;
            delta_b = target;
            
            // Update weights and bias
            w1 = w1 + delta_w1;
            w2 = w2 + delta_w2;
            bias = bias + delta_b;
            
            // Transition to next state
            present_state = state;
            next_state = 8;
            
            // Increment iteration counter
            iteration = iteration + 1;
        end
        1: begin
            // Update weights and bias
            present_state = state;
            next_state = 8;
        end
        2: begin
            // Update weights and bias
            present_state = state;
            next_state = 8;
        end
        3: begin
            // Update weights and bias
            present_state = state;
            next_state = 8;
        end
        4: begin
            // Update weights and bias
            present_state = state;
            next_state = 8;
        end
        5: begin
            // Update weights and bias
            present_state = state;
            next_state = 8;
        end
        6: begin
            // Update weights and bias
            present_state = state;
            next_state = 8;
        end
        7: begin
            // Update weights and bias
            present_state = state;
            next_state = 8;
        end
        8: begin
            // Loop through training iterations
            if (iteration < 10) begin
                iteration = iteration + 1;
                next_state = 9;
            else
                next_state = 0;
            end
        end
        9: begin
            // Return to initial state
            next_state = 0;
        end
        10: begin
            // Reset for next iteration
            w1 = 4'b0000;
            w2 = 4'b0000;
            bias = 4'b0000;
            present_state = 4'b0000;
            next_state = 1;
        end
    endcase
endmodule