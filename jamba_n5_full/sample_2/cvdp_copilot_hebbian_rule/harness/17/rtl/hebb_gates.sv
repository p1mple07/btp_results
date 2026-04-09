module hebbian_rule (
    input clk,
    input rst,
    input start,
    input [3:0] a,
    input [3:0] b,
    input gate_select,
    output reg [3:0] w1,
    output reg [3:0] w2,
    output reg [3:0] bias,
    output reg [3:0] present_state,
    output reg next_state
);

reg [3:0] w1_cur, w2_cur, bias_cur;
reg [3:0] target;
reg [3:0] delta_w1, delta_w2, delta_b;
reg current_state;

initial begin
    w1_cur = 4'b0000;
    w2_cur = 4'b0000;
    bias_cur = 4'b0000;
    current_state = 0;
end

always @(posedge clk) begin
    if (rst)
        w1_cur <= 4'b0000;
        w2_cur <= 4'b0000;
        bias_cur <= 4'b0000;
        current_state = 0;
    else begin
        case (current_state)
            0: // Capture inputs
                w1_cur = a[3:0];
                w2_cur = b[3:0];
                next_state = 1;
            1: // Assign targets
                if (gate_select == 2'b00) target = 4'b0001;
                else if (gate_select == 2'b01) target = 4'b0011;
                else if (gate_select == 2'b10) target = 4'b1000;
                else if (gate_select == 2'b11) target = 4'b1111;
                next_state = 2;
            2: // Compute deltas
                delta_w1 = w1_cur * target;
                delta_w2 = w2_cur * target;
                delta_b = target;
                w1_cur = w1_cur + delta_w1;
                w2_cur = w2_cur + delta_w2;
                bias_cur = bias_cur + delta_b;
                next_state = 3;
        endcase
    end
end

always @() begin
    if (current_state == 3) begin
        target = target_table[gate_select];
        next_state = 4;
    end
end

endmodule
