module hebbian_rule #(
    parameter NUM_INPUTS = 2,
    parameter NUM_GATES = 4
)(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [3:0] a,
    input logic [3:0] b,
    input logic [1:0] gate_select,
    output logic [3:0] w1,
    output logic [3:0] w2,
    output logic [3:0] bias,
    output logic [3:0] present_state,
    output logic [3:0] next_state
);

    // Internal signals
    logic [3:0] x1, x2, target;
    logic [3:0] delta_w1, delta_w2, delta_b;

    // FSM states
    localparam [3:0] FSM_STATE_0 = 4'b0000,
                            FSM_STATE_1 = 4'b0001,
                            FSM_STATE_2 = 4'b0010,
                            FSM_STATE_3 = 4'b0011,
                            FSM_STATE_4 = 4'b0100,
                            FSM_STATE_5 = 4'b0101,
                            FSM_STATE_6 = 4'b0110,
                            FSM_STATE_7 = 4'b1000,
                            FSM_STATE_8 = 4'b1001,
                            FSM_STATE_9 = 4'b1010,
                            FSM_STATE_10 = 4'b1011;

    // Initialize weights and bias
    logic [3:0] w1_init = 4'b0000, w2_init = 4'b0000, bias_init = 4'b0000;

    // Define a gate_target submodule
    logic [3:0] gate_target(input logic [3:0] x1, input logic [3:0] x2, input logic [1:0] gate_select, output logic [3:0] target);

    // FSM implementation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            w1 <= w1_init;
            w2 <= w2_init;
            bias <= bias_init;
            present_state <= FSM_STATE_0;
            next_state <= FSM_STATE_0;
        end else if (start && !present_state) begin
            present_state <= FSM_STATE_1;
            next_state <= FSM_STATE_2;
        end else if (present_state == FSM_STATE_2 || present_state == FSM_STATE_3) begin
            target <= gate_target(x1, x2, gate_select);
            delta_w1 <= x1 * target;
            delta_w2 <= x2 * target;
            delta_b <= target;
            w1 <= w1 + delta_w1;
            w2 <= w2 + delta_w2;
            bias <= bias + delta_b;
            present_state <= FSM_STATE_7;
            next_state <= FSM_STATE_8;
        end else if (present_state == FSM_STATE_8) begin
            // Loop through iterations
            // This part of the code should be modified to loop through training iterations
            // For now, we will simulate a single iteration
            present_state <= FSM_STATE_9;
            next_state <= FSM_STATE_10;
        end else if (present_state == FSM_STATE_10) begin
            // Return to initial state after training
            present_state <= FSM_STATE_0;
            next_state <= FSM_STATE_1;
        end
    end

    // Define the gate_target submodule
    logic [3:0] gate_target(input logic [3:0] x1, input logic [3:0] x2, input logic [1:0] gate_select, output logic [3:0] target);
    always @(gate_select) begin
        case (gate_select)
            2'b00: target = x1 & x2; // AND
            2'b01: target = x1 | x2; // OR
            2'b10: target = ~(x1 & x2); // NAND
            2'b11: target = ~(x1 | x2); // NOR
        endcase
    end

endmodule
