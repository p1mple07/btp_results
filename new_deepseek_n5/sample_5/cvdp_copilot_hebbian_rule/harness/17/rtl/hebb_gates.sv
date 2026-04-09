module hebbian_rule (
    input wire [INPUT_WIDTH-1:0] a,
    input wire [INPUT_WIDTH-1:0] b,
    input wire gate_select,
    input wire clk,
    input wire rst,
    output register signed [INPUT_WIDTH-1:0] w1,
    output register signed [INPUT_WIDTH-1:0] w2,
    output register signed [INPUT_WIDTH-1:0] bias,
    output register [2*INPUT_WIDTH-1:0] present_state,
    output register [2*INPUT_WIDTH-1:0] next_state
);

    // FSM state variable
    reg state = 0;

    // State 0: Reset state
    always @posedge rst) 
        state = 0;

    // State 1: Capture inputs
    always @negedge rst) 
        if (start) begin
            state = 1;
            present_state <= 0;
            next_state <= 1;
        end

    // State 2: Assign target based on gate select
    always @negedge rst) 
        if (start && state == 2) begin
            case (gate_select)
                2'b00: target = a & b;
                2'b01: target = a | b;
                2'b10: target = ~a & ~b;
                2'b11: target = ~a | ~b;
            endcase
            state = 3;
            present_state <= 2;
            next_state <= 3;
        end

    // State 3: Compute deltas
    always @negedge rst) 
        if (start && state == 3) begin
            x1 = a;
            x2 = b;
            delta_w1 = x1 & target;
            delta_w2 = x2 & target;
            delta_b = target;
            state = 4;
            present_state <= 3;
            next_state <= 4;
        end

    // State 4: Update weights and bias
    always @negedge rst) 
        if (start && state == 4) begin
            w1 = w1 + delta_w1;
            w2 = w2 + delta_w2;
            bias = bias + delta_b;
            state = 5;
            present_state <= 4;
            next_state <= 5;
        end

    // State 5: Loop through training iterations
    always @negedge rst) 
        if (start && state == 5) begin
            state = 6;
            present_state <= 5;
            next_state <= 6;
        end

    // State 6: Return to initial state
    always @negedge rst) 
        if (start && state == 6) begin
            state = 0;
            present_state <= 6;
            next_state <= 0;
        end

endmodule