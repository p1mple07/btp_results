module perceptron_gates #(
    parameter int WEIGHT_WIDTH = 4,
    parameter int BIAS_WIDTH = 4,
    parameter int INPUT_WIDTH = 4,
    parameter logic [1:0] GATE_SELECT = 2'b00
) (
    input logic clk,
    input logic rst_n,
    input [INPUT_WIDTH-1:0] x1,
    input [INPUT_WIDTH-1:0] x2,
    input logic learning_rate,
    input [INPUT_WIDTH-1:0] threshold,
    input [1:0] gate_select,
    output logic present_addr,
    output logic stop,
    output logic input_index,
    output [WEIGHT_WIDTH-1:0] percep_w1,
    output [WEIGHT_WIDTH-1:0] percep_w2,
    output [BIAS_WIDTH-1:0] percep_bias,
    output [INPUT_WIDTH-1:0] y_in,
    output logic y
);

    // Define local variables
    logic [WEIGHT_WIDTH-1:0] prev_percep_w1, prev_percep_w2, prev_percep_bias;
    logic [INPUT_WIDTH-1:0] prev_input_index;

    // Define submodules
    gate_target gate_target(
        .gate_select(gate_select),
        .o_1(o_1),
        .o_2(o_2),
        .o_3(o_3),
        .o_4(o_4)
    );

    // Define the microcode ROM
    microcode_rom #(.WIDTH(WEIGHT_WIDTH), .LENGTH(6)) microcode_rom(
        .clk(clk),
        .rst(rst_n),
        .present_addr(present_addr),
        .input_index(input_index),
        .y_in(y_in),
        .prev_percep_wt_1(prev_percep_w1),
        .prev_percep_wt_2(prev_percep_w2),
        .prev_percep_bias(prev_percep_bias),
        .gate_select(gate_select),
        .microcode(
            .{
                .addr, .action
            }
        )
    );

    // Define the main functionality
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            percep_w1 <= {1'b0, {WEIGHT_WIDTH{1'b0}}};
            percep_w2 <= {1'b0, {WEIGHT_WIDTH{1'b0}}};
            percep_bias <= {BIAS_WIDTH{1'b0}};
            y_in <= {1'b0, {WEIGHT_WIDTH{1'b0}}};
            stop <= 1'b0;
            input_index <= {3'b0, 3'b0, 3'b0};
            prev_percep_w1 <= percep_w1;
            prev_percep_w2 <= percep_w2;
            prev_percep_bias <= percep_bias;
        end else begin
            case (present_addr)
                4'b0000: begin
                    // Action 0: Initialize weights and bias to zero
                    percep_w1 <= {1'b0, {WEIGHT_WIDTH{1'b0}}};
                    percep_w2 <= {1'b0, {WEIGHT_WIDTH{1'b0}}};
                    percep_bias <= {BIAS_WIDTH{1'b0}};
                    y_in <= {1'b0, {WEIGHT_WIDTH{1'b0}}};
                    // No action for stop signal in initialization
                    input_index <= {3'b0, 3'b0, 3'b0};
                end
                4'b0001: begin
                    // Action 1: Compute output y_in
                    y_in = percep_bias + (x1 * percep_w1) + (x2 * percep_w2);
                    if (y_in < threshold)
                        y = 4'b0000;
                    else
                        y = 4'b1111;
                    // No action for stop signal in output computation
                    input_index <= {3'b0, 3'b0, 3'b0};
                end
                4'b0010: begin
                    // Action 2: Select target value based on gate_select and input_index
                    gate_target gate_target_inst(.gate_select(gate_select), .o_1(o_1), .o_2(o_2), .o_3(o_3), .o_4(o_4));
                    input_index <= o_1;
                    prev_percep_w1 <= percep_w1;
                end
                4'b0011: begin
                    // Action 3: Update weights and bias if y != target
                    if (y != gate_target_inst.o_1)
                        percep_w1 <= percep_w1 + (learning_rate * x1 * gate_target_inst.o_1);
                    else
                        percep_w1 <= prev_percep_w1;
                    if (y != gate_target_inst.o_2)
                        percep_w2 <= percep_w2 + (learning_rate * x2 * gate_target_inst.o_2);
                    else
                        percep_w2 <= prev_percep_w2;
                    if (y != gate_target_inst.o_3)
                        percep_bias <= percep_bias + (learning_rate * gate_target_inst.o_3);
                    else
                        percep_bias <= prev_percep_bias;
                    // No action for stop signal in weight updates
                    input_index <= {3'b0, 3'b0, 3'b0};
                end
                4'b0100: begin
                    // Action 4: Check for convergence
                    if (percep_w1 == prev_percep_w1 && percep_w2 == prev_percep_w2 && percep_bias == prev_percep_bias)
                        stop <= 1'b1;
                    else
                        prev_percep_w1 <= percep_w1;
                        prev_percep_w2 <= percep_w2;
                        prev_percep_bias <= percep_bias;
                    input_index <= {3'b0, 3'b0, 3'b0};
                end
            endcase
        end
    end

endmodule
