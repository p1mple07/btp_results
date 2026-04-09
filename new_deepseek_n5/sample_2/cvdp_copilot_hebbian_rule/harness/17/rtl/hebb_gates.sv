module hebbian_rule (
    input clock,
    input rst,
    input start,
    input [3:0] a,
    input [3:0] b,
    input [1:0] gate_select,
    output reg w1,
    output reg w2,
    output reg bias,
    output reg present_state,
    output reg next_state
);

    // State variable (0: Reset, 1: Capture, 2: Target, 3: Compute Deltas, 4: Update, 5: Loop, 6: Return)
    reg state = 0;

    // Weight registers
    reg [3:0] w1_reg = 4'b0000;
    reg [3:0] w2_reg = 4'b0000;
    reg [3:0] bias_reg = 4'b0000;

    // Present and next state registers
    reg [3:0] present_state_reg = 0;
    reg [3:0] next_state_reg = 0;

    // Internal registers
    reg [3:0] x1_reg;
    reg [3:0] x2_reg;
    reg [3:0] t_reg;
    reg [3:0] delta_w1_reg;
    reg [3:0] delta_w2_reg;
    reg [3:0] delta_b_reg;

    // Control signals
    reg [1:0] control = 0;

    // Initialize weights and bias
    always @(posedge clock or posedge rst) begin
        if (rst) begin
            state = 0;
            w1_reg = 4'b0000;
            w2_reg = 4'b0000;
            bias_reg = 4'b0000;
            present_state_reg = 0;
            next_state_reg = 0;
        end else begin
            // State machine logic
            case (state)
                0: present_state_reg = 0;
                   next_state_reg = 1;
                   control = 0;
                   // Capture inputs
                   x1_reg = a;
                   x2_reg = b;
                   state = 1;
                1: // Capture inputs
                   present_state_reg = 1;
                   next_state_reg = 2;
                   control = 0;
                   // Select target based on gate select
                   case (gate_select)
                       2'b00: t_reg = x1_reg & x2_reg;
                       2'b01: t_reg = x1_reg | x2_reg;
                       2'b10: t_reg = ~ (x1_reg & x2_reg);
                       2'b11: t_reg = ~ (x1_reg | x2_reg);
                   endcase
                   state = 2;
                2: // Compute deltas
                   delta_w1_reg = x1_reg & t_reg;
                   delta_w2_reg = x2_reg & t_reg;
                   delta_b_reg = t_reg;
                   present_state_reg = 2;
                   next_state_reg = 3;
                   control = 0;
                   state = 3;
                3: // Update weights and bias
                   w1_reg = w1_reg + delta_w1_reg;
                   w2_reg = w2_reg + delta_w2_reg;
                   bias_reg = bias_reg + delta_b_reg;
                   present_state_reg = 3;
                   next_state_reg = 5;
                   control = 0;
                   state = 4;
                4: // Loop through training iterations
                   present_state_reg = 4;
                   next_state_reg = 5;
                   control = 0;
                   state = 5;
                5: // Return to initial state
                   present_state_reg = 5;
                   next_state_reg = 0;
                   control = 0;
                   state = 0;
                default: 
                   present_state_reg = 6;
                   next_state_reg = 6;
                   control = 0;
                   state = 6;
            end
        end
    end

    // Assign outputs
    w1 = w1_reg;
    w2 = w2_reg;
    bias = bias_reg;
    present_state = present_state_reg;
    next_state = next_state_reg;

    // FSM control logic
    always @(posedge clock) begin
        if (start) begin
            if (rst) 
                state = 0;
            else 
                state = (state + 1) % 7;
            end
        end
    end

endmodule