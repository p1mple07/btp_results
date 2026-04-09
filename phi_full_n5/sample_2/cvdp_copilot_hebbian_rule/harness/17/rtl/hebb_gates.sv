module hebbian_rule (
    input clk,
    input rst,
    input start,
    input [3:0] a,
    input [3:0] b,
    input [1:0] gate_select,
    output reg [3:0] w1,
    output reg [3:0] w2,
    output reg [3:0] bias,
    output [3:0] present_state,
    output [3:0] next_state
);

    reg [3:0] x1, x2;
    reg [3:0] t1;
    reg [3:0] delta_w1, delta_w2, delta_b;

    // Initialize FSM states
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            present_state <= 4'b0000;
            next_state <= 4'b0000;
        end else if (start) begin
            present_state <= 4'b0000;
            next_state <= 4'b0001; // Reset state
        end
    end

    // Capture inputs
    always @(posedge clk) begin
        if (start) begin
            x1 <= a;
            x2 <= b;
            next_state <= 4'b0002; // Capture state
        end
    end

    // Gate target selection
    always @(posedge clk) begin
        case (gate_select)
            2'b00: t1 = a & b; // AND gate
            2'b01: t1 = a | b; // OR gate
            2'b10: t1 = ~(a | b); // NAND gate
            2'b11: t1 = ~(a & b); // NOR gate
        endcase
        next_state <= (gate_select == 2'b00) ? 4'b0003 : (gate_select == 2'b01) ? 4'b0004 : (gate_select == 2'b10) ? 4'b0005 : 4'b0006;
    end

    // Compute deltas for weights and bias
    always @(posedge clk) begin
        if (next_state == 4'b0003 || next_state == 4'b0005) begin
            delta_w1 <= x1 * t1;
            delta_w2 <= x2 * t1;
            delta_b <= t1;
            next_state <= (next_state == 4'b0003) ? 4'b0007 : (next_state == 4'b0005) ? 4'b0008 : next_state;
        end
    end

    // Update weights and bias
    always @(posedge clk) begin
        if (next_state == 4'b0008) begin
            w1 <= w1 + delta_w1;
            w2 <= w2 + delta_w2;
            bias <= bias + delta_b;
            next_state <= (next_state == 4'b0008) ? 4'b0009 : next_state;
        end
    end

    // Loop through training iterations
    always @(posedge clk) begin
        if (next_state == 4'b0009) begin
            present_state <= next_state;
            next_state <= (next_state == 4'b0009) ? 4'b0010 : next_state;
        end
    end

    // Return to initial state
    always @(posedge clk) begin
        if (next_state == 4'b0010) begin
            present_state <= 4'b0000;
            next_state <= 4'b0000;
        end
    end

endmodule
