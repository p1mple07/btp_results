module hebbian_rule #(parameter WEIGHT_BITS = 4) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [1:0] gate_select,
    output reg [WEIGHT_BITS-1:0] w1,
    output reg [WEIGHT_BITS-1:0] w2,
    output reg [WEIGHT_BITS-1:0] bias,
    output reg [WEIGHT_BITS-1:0] present_state,
    output reg [WEIGHT_BITS-1:0] next_state
);

    // Internal registers
    reg [WEIGHT_BITS-1:0] x1, x2, target, delta_w1, delta_w2, delta_b;
    reg [WEIGHT_BITS-1:0] w1_new, w2_new, bias_new;

    // State register
    reg [WEIGHT_BITS-1:0] state_reg = 4'b0000;

    // FSM logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= 4'b0000;
            x1 <= 4'b0;
            x2 <= 4'b0;
            target <= 4'b0;
            delta_w1 <= 0;
            delta_w2 <= 0;
            delta_b <= 0;
            w1 <= 4'b0;
            w2 <= 4'b0;
            bias <= 4'b0;
            present_state <= 4'b0;
            next_state <= 4'b0;
        end else if (start) begin
            state_reg <= 4'b0001; // Capture inputs
        end else if (state_reg == 4'b0001) begin
            x1 <= a;
            x2 <= b;
            target <= get_target(gate_select);
        end else if (state_reg == 4'b0002 || state_reg == 4'b0003 || state_reg == 4'b0004) begin
            delta_w1 = x1 * target;
            delta_w2 = x2 * target;
            delta_b = target;
        end else if (state_reg == 4'b0005) begin
            w1_new = w1 + delta_w1;
            w2_new = w2 + delta_w2;
            bias_new = bias + delta_b;
        end else if (state_reg == 4'b0006) begin
            w1 <= w1_new;
            w2 <= w2_new;
            bias <= bias_new;
        end else if (state_reg == 4'b0007) begin
            present_state <= next_state;
            next_state <= state_reg;
        end else if (state_reg == 4'b0008) begin
            state_reg <= 4'b0000; // Return to initial state
        end
    end

    // Target selector logic
    function [WEIGHT_BITS-1:0] get_target(input [1:0] gate_select);
        case (gate_select)
            2'b00: return 4'b0001;
            2'b01: return 4'b0001;
            2'b10: return 4'b0001;
            2'b11: return 4'b0001;
        endcase
    endfunction

endmodule
