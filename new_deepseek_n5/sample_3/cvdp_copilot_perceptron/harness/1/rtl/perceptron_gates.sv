module perceptron_gates(
    input clock,
    input rst_n,
    input [3:0] x1,
    input [3:0] x2,
    input learning_rate,
    input [3:0] threshold,
    input [1:0] gate_select
    output reg percep_w1,
    output reg percep_w2,
    output reg percep_bias,
    output reg present_addr,
    output reg stop,
    output reg input_index,
    output reg [3:0] y_in,
    output reg [3:0] y
);

// Microcode ROM instructions
reg [5:0] microcode_rom = [
    6'd0: 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    6'd1: 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    6'd2: 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    6'd3: 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    6'd4: 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    6'd5: 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0
];

// Initialize weights and biases
reg [3:0] prev_percep_w1, prev_percep_w2, prev_percep_bias;
reg [3:0] percep_w1, percep_w2, percep_bias;
reg [3:0] y_in, y;
reg [3:0] input_index;

// Target values based on gate type
reg [4:0] o_1, o_2, o_3, o_4;
always @* begin
    case(gate_select)
        2'b00: o_1 = 4'd1; o_2 = -4'd1; o_3 = -4'd1; o_4 = -4'd1;
        2'b01: o_1 = 4'd1; o_2 = 4'd1; o_3 = 4'd1; o_4 = -4'd1;
        2'b10: o_1 = 4'd1; o_2 = 4'd1; o_3 = 4'd1; o_4 = -4'd1;
        2'b11: o_1 = 4'd1; o_2 = -4'd1; o_3 = -4'd1; o_4 = -4'd1;
    endcase
end

// Main training loop
always @posedge clock begin
    if (rst_n) begin
        percep_w1 = 4'd0;
        percep_w2 = 4'd0;
        percep_bias = 4'd0;
        present_addr = 4'd0;
        stop = 1;
        input_index = 3'd0;
        y_in = 4'd0;
        y = 4'd0;
        present_addr = 4'd5;
        // Start training with first input vector
        present_addr = 4'd1;
        #10ns;
    end else begin
        // Execute microcode ROM instruction
        case(present_addr)
            6'd0: begin
                // Initialization
                percep_w1 = 4'd0;
                percep_w2 = 4'd0;
                percep_bias = 4'd0;
                present_addr = 4'd1;
                #10ns;
            end
            6'd1: begin
                // Compute perceptron output
                y_in = (x1 & percep_w1) + (x2 & percep_w2) + percep_bias;
                y = y_in > threshold ? 4'd1 : -4'd1;
                present_addr = 4'd2;
                #10ns;
            end
            6'd2: begin
                // Select target
                case(gate_select)
                    2'b00: o_1 = 4'd1; o_2 = -4'd1; o_3 = -4'd1; o_4 = -4'd1;
                    2'b01: o_1 = 4'd1; o_2 = 4'd1; o_3 = 4'd1; o_4 = -4'd1;
                    2'b10: o_1 = 4'd1; o_2 = 4'd1; o_3 = 4'd1; o_4 = -4'd1;
                    2'b11: o_1 = 4'd1; o_2 = -4'd1; o_3 = -4'd1; o_4 = -4'd1;
                endcase
                present_addr = 4'd3;
                #10ns;
            end
            6'd3: begin
                // Update weights and bias
                if (y != o_1) begin
                    wt1_update = learning_rate & (x1 & o_1);
                    wt2_update = learning_rate & (x2 & o_1);
                    bias_update = learning_rate & o_1;
                else begin
                    wt1_update = 4'd0;
                    wt2_update = 4'd0;
                    bias_update = 4'd0;
                end
                percep_w1 = percep_w1 + wt1_update;
                percep_w2 = percep_w2 + wt2_update;
                percep_bias = percep_bias + bias_update;
                present_addr = 4'd4;
                #10ns;
            end
            6'd4: begin
                // Check for convergence
                if (percep_w1 == prev_percep_w1 &
                    percep_w2 == prev_percep_w2 &
                    percep_bias == prev_percep_bias) begin
                    stop = 1;
                    present_addr = 4'd5;
                else begin
                    prev_percep_w1 = percep_w1;
                    prev_percep_w2 = percep_w2;
                    prev_percep_bias = percep_bias;
                    present_addr = 4'd4 + 1;
                end
                #10ns;
            end
            6'd5: begin
                // Finalize updates and prepare for next epoch
                percep_w1 = percep_w1 + wt1_update;
                percep_w2 = percep_w2 + wt2_update;
                percep_bias = percep_bias + bias_update;
                present_addr = 4'd5;
                #10ns;
            end
        end
    end
end

endmodule