module hebbian_rule (
    input clk,
    input rst,
    input start,
    input a[3:0],
    input b[3:0],
    input gate_select[1:0],
    output reg w1,
    output reg w2,
    output reg bias,
    output present_state,
    output next_state
);

    // Internal state variables
    logic [3:0] state;
    logic [3:0] next_state;
    logic started;
    logic capture_inputs;
    logic assign_targets;
    logic compute_deltas;
    logic update_weights;

    // Initialization
    always @(posedge clk) begin
        if (!started) begin
            state <= 0;
            next_state <= 0;
        end else if (state == 0) begin
            state <= 1;
        end else if (state == 1) begin
            state <= 2;
        end else if (state == 2) begin
            state <= 3;
        end else if (state == 3) begin
            state <= 4;
        end else if (state == 4) begin
            state <= 5;
        end else if (state == 5) begin
            state <= 6;
        end else if (state == 6) begin
            state <= 7;
        end else if (state == 7) begin
            state <= 8;
        end else if (state == 8) begin
            state <= 9;
        end else if (state == 9) begin
            state <= 10;
        end else if (state == 10) begin
            state <= 11;
        end
    end

    // Step 1: Initialize weights and bias to zero
    always @(posedge clk) begin
        if (started && state == 0) begin
            w1 <= 4'b0000;
            w2 <= 4'b0000;
            bias <= 4'b0000;
        end
    end

    // Step 2a: Capture inputs
    always @(posedge clk) begin
        if (capture_inputs) begin
            x1 <= a[3:0];
            x2 <= b[3:0];
        end
    end

    // Step 2b: Assign targets
    always @(posedge clk) begin
        if (assign_targets) begin
            t1 <= 4'b0001;   // AND
            t2 <= 4'b0010;   // OR
            t3 <= 4'b0100;   // NAND
            t4 <= 4'b1000;   // NOR
        end else if (assign_targets) begin
            assign_targets <= 0;
        end
    end

    // Step 2c: Compute deltas
    always @(posedge clk) begin
        if (compute_deltas) begin
            delta_w1 = x1 * t1;
            delta_w2 = x2 * t2;
            delta_b = t1;
        end
    end

    // Step 3: Update weights and bias
    always @(posedge clk) begin
        if (update_weights) begin
            w1 <= w1 + delta_w1;
            w2 <= w2 + delta_w2;
            bias <= bias + delta_b;
        end
    end

    // Step 4: Convergence checks (just a placeholder)
    always @(posedge clk) begin
        if (done_convergence) begin
            next_state <= 0;
        end
    end

endmodule
