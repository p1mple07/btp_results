module perceptron_gates #(
    parameter BITWIDTH_INPUT = 4,
    parameter BITWIDTH_WEIGHT = 4,
    parameter BITWIDTH_BIAS = 4,
    parameter BITWIDTH_TARGET = 3,
    parameter BITWIDTH_PREV_WEIGHT = 4,
    parameter BITWIDTH_PREV_BIAS = 4,
    parameter BITWIDTH_STOP = 1
) (
    input clk,
    input rst_n,
    input [BITWIDTH_INPUT-1:0] x1,
    input [BITWIDTH_INPUT-1:0] x2,
    input [BITWIDTH_TARGET-1:0] threshold,
    input [1:0] gate_select,
    input [BITWIDTH_TARGET-1:0] input_index,
    output [BITWIDTH_WEIGHT-1:0] percep_w1,
    output [BITWIDTH_WEIGHT-1:0] percep_w2,
    output [BITWIDTH_BIAS-1:0] percep_bias,
    output present_addr,
    output stop,
    output [BITWIDTH_TARGET-1:0] y_in,
    output [BITWIDTH_TARGET-1:0] y,
    output [BITWIDTH_PREV_WEIGHT-1:0] prev_percep_wt_1,
    output [BITWIDTH_PREV_WEIGHT-1:0] prev_percep_wt_2,
    output [BITWIDTH_PREV_BIAS-1:0] prev_percep_bias
);

    // Define submodules
    gate_target u_gate_target (
        .gate_select(gate_select),
        .o_1(), .o_2(), .o_3(), .o_4()
    );
    microcode_rom u_microcode_rom (
        .clk, .rst, .addr, .weights, .bias, .target, .input_index
    );

    // Define internal signals
    logic [BITWIDTH_WEIGHT-1:0] wt1_update, wt2_update, bias_update;
    logic [BITWIDTH_BIAS-1:0] prev_percep_wt_1, prev_percep_wt_2, prev_percep_bias;
    logic [BITWIDTH_TARGET-1:0] y_out, target;

    // Initialize weights and bias
    always_comb
    begin
        if (!rst_n)
            percep_w1 = 4'd0;
        percep_w2 = 4'd0;
        percep_bias = 4'd0;
        prev_percep_wt_1 = 4'd0;
        prev_percep_wt_2 = 4'd0;
        prev_percep_bias = 4'd0;
    end

    // Compute output
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            y_in = percep_bias + (x1 * percep_w1) + (x2 * percep_w2);
            y = (y_in > threshold) ? 4'd1 : (y_in < -threshold) ? 4'd0 : -4'd1;
        end
    end

    // Select target value
    always_comb
    begin
        target = u_gate_target.o_1();
        case (gate_select)
            2'b00: target = 4'd1;
            2'b01: target = 4'd1;
            2'b10: target = 4'd1;
            2'b11: target = 4'd1;
        endcase
    end

    // Update weights and bias
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            if (target != y) begin
                wt1_update = learning_rate * x1 * target;
                wt2_update = learning_rate * x2 * target;
                bias_update = learning_rate * target;
            end else begin
                wt1_update = 4'd0;
                wt2_update = 4'd0;
                bias_update = 4'd0;
            end
        end
    end

    // Compare weights and bias to check for convergence
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            if (wt1_update == prev_percep_wt_1 && wt2_update == prev_percep_wt_2 && bias_update == prev_percep_bias)
                stop = 1'b1;
            else
                prev_percep_wt_1 = wt1_update;
            prev_percep_wt_2 = wt2_update;
            prev_percep_bias = bias_update;
        end
    end

    // Update weights and bias signals
    assign percep_w1 = percep_w1 + wt1_update;
    assign percep_w2 = percep_w2 + wt2_update;
    assign percep_bias = percep_bias + bias_update;

    // Output the current address for the microcode ROM
    assign present_addr = u_microcode_rom.addr;

endmodule
