module perceptron_gates(
    input clock,
    input rst_n,
    input [3:0] x1,
    input [3:0] x2,
    input learning_rate,
    input [3:0] threshold,
    input [1:0] gate_select,
    output [3:0] percep_w1,
    output [3:0] percep_w2,
    output [3:0] percep_bias,
    output stop,
    output [2:0] input_index,
    output [3:0] y_in,
    output [4:0] y
);

    // Microcode ROM table
    static rom_table = [
        0b000000, // Initialize weights
        0b000001, // Compute output
        0b000010, // Select target
        0b000011, // Update weights
        0b000100, // Check convergence
        0b000101  // Finalize updates
    ];

    // State variables
    reg present_addr = 4'd0;
    reg action = 0;
    reg [3:0] w1 = 4'd1;
    reg [3:0] w2 = 4'd1;
    reg [3:0] bias = 4'd1;
    reg y_out = 4'd1;
    reg y_prev = 4'd1;
    reg [3:0] prev_w1_update = 4'd0;
    reg [3:0] prev_w2_update = 4'd0;
    reg [3:0] prev_bias_update = 4'd0;

    // Target generation
    gate_target gt(gate_select, input_index, o_1, o_2, o_3, o_4);

    // FSM
    always clocked (posedge clock) begin
        case (action)
            0: 
                // Initialize weights and bias
                present_addr = 4'd0;
                w1 = 4'd1;
                w2 = 4'd1;
                bias = 4'd1;
                y_out = 4'd1;
                y_prev = 4'd1;
                prev_w1_update = 4'd0;
                prev_w2_update = 4'd0;
                prev_bias_update = 4'd0;
                action = 1;
                present_addr = 4'd1;
                #1ns;
            1: 
                // Compute output
                y_in = (x1 * w1) + (x2 * w2) + bias;
                y_out = y_in >= threshold ? 4'd1 : -4'd1;
                present_addr = present_addr + 1;
                action = 2;
                #1ns;
            2: 
                // Select target
                o_1 = gt.o_1;
                o_2 = gt.o_2;
                o_3 = gt.o_3;
                o_4 = gt.o_4;
                present_addr = present_addr + 1;
                action = 3;
                #1ns;
            3: 
                // Update weights
                if (y_out != y_in) begin
                    prev_w1_update = learning_rate * x1 * y_in;
                    prev_w2_update = learning_rate * x2 * y_in;
                    prev_bias_update = learning_rate * y_in;
                else begin
                    prev_w1_update = 4'd0;
                    prev_w2_update = 4'd0;
                    prev_bias_update = 4'd0;
                end
                present_addr = present_addr + 1;
                action = 4;
                #1ns;
            4: 
                // Check convergence
                if (w1 == percep_w1 && w2 == percep_w2 && bias == percep_bias) begin
                    stop = 1;
                    present_addr = 4'd0;
                    action = 5;
                else begin
                    percep_w1 = w1;
                    percep_w2 = w2;
                    percep_bias = bias;
                    present_addr = present_addr + 1;
                    action = 0;
                end
                #1ns;
            default:
                break;
        endcase
    end

    // Output signals
    output_perceptron_response(y_out);
    output_perceptron_bias(bias);
    output_perceptron_w1(w1);
    output_perceptron_w2(w2);
    output_stop(stop);
    output_input_index(input_index);
    output_y_in(y_in);
    output_y(y_out);
endmodule