module hebbian_rule #(
    parameter NUM_INPUTS = 2,
    parameter NUM_OUTPUTS = 1,
    parameter NUM_STATES = 11
)(
    input clk,
    input rst,
    input start,
    input [NUM_INPUTS-1:0] a,
    input [NUM_INPUTS-1:0] b,
    input [1:0] gate_select,
    output reg [NUM_OUTPUTS-1:0] w1,
    output reg [NUM_OUTPUTS-1:0] w2,
    output reg [NUM_OUTPUTS-1:0] bias,
    output reg [NUM_STATES-1:0] present_state,
    output reg [NUM_STATES-1:0] next_state
);

    // FSM state register
    reg [NUM_STATES-1:0] fsm_state = 0;

    // Registers for input vectors
    reg [NUM_INPUTS-1:0] x1, x2;

    // Registers for target values
    reg [NUM_OUTPUTS-1:0] target;

    // Weight and bias registers
    reg [NUM_OUTPUTS-1:0] weights [NUM_INPUTS-1:0];
    reg [NUM_OUTPUTS-1:0] bias_reg;

    // Gate target submodule
    logic [NUM_OUTPUTS-1:0] gate_target[NUM_GATES-1:0];

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            fsm_state <= 0;
        else if (start)
            fsm_state <= 1;
        else
            case (fsm_state)
                0: // Reset
                    present_state <= 0;
                    next_state <= 0;
                1: // Capture inputs
                    x1 <= a;
                    x2 <= b;
                    next_state <= 2;
                2: // Assign target based on gate_select
                    case (gate_select)
                        2'b00: target = x1 & x2; // AND gate
                        2'b01: target = x1 | x2; // OR gate
                        2'b10: target = ~(x1 & x2); // NAND gate
                        2'b11: target = ~(x1 | x2); // NOR gate
                        default: target = x1;
                    endcase
                    next_state <= 3;
                3: // Compute deltas for weights and bias
                    weights[0] <= x1 * target;
                    weights[1] <= x2 * target;
                    bias_reg <= target;
                    next_state <= 4;
                4: // Update weights and bias
                    w1 <= weights[0] + w1;
                    w2 <= weights[1] + w2;
                    bias <= bias_reg + bias;
                    next_state <= 5;
                5: // Loop through training iterations
                    next_state <= 6;
                6: // Return to initial state
                    present_state <= 0;
                    next_state <= 0;
                    default: next_state <= 0;
            endcase
    end

endmodule
