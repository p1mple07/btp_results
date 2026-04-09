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

    // State variable: 4-bit state (0-10)
    reg [3:0] state = 0;

    // Weight registers
    reg signed [3:0] x1, x2;
    reg signed [3:0] w1_reg, w2_reg;
    reg signed [3:0] bias_reg;

    // Target register
    reg signed [3:0] target;

    // Control signals
    reg [1:0] gate_target;

    // Initialize weights and bias to 0
    always_ensured begin
        x1 = 4'b0000;
        x2 = 4'b0000;
        w1_reg = 4'b0000;
        w2_reg = 4'b0000;
        bias_reg = 4'b0000;
    end

    // FSM state transitions
    always clock's edge sensitive+:
        case (state)
            0: 
                if (rst) 
                    state = 0;
                else 
                    state = 1;
            1: 
                if (start) 
                    state = 2;
                else 
                    state = 0;
            2: 
                x1 = a;
                x2 = b;
                state = 3;
            3: 
                gate_target = gate_select;
                state = 4;
            4: 
                target = (gate_target[0] & (x1 & x2)) | (gate_target[1] & (x1 | x2)) | (!gate_target[0] & !x1 & !x2);
                state = 5;
            5: 
                delta_w1 = x1 * target;
                delta_w2 = x2 * target;
                delta_b = target;
                w1_reg = w1_reg + delta_w1;
                w2_reg = w2_reg + delta_w2;
                bias_reg = bias_reg + delta_b;
                state = 6;
            6: 
                state = 7;
            7: 
                state = 8;
            8: 
                state = 9;
            9: 
                state = 10;
            10: 
                state = 0;
        endcase
    end

    // Output the results
    present_state = state;
    next_state = state;
    w1 = w1_reg;
    w2 = w2_reg;
    bias = bias_reg;

endmodule