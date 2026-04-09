module perceptron_gates (
    input clock,
    input rst_n,
    input [3:0] x1,
    input [3:0] x2,
    input learning_rate,
    input [3:0] threshold,
    input [1:0] gate_select,
    output reg percep_w1,
    output reg percep_w2,
    output reg percep_bias,
    output reg stop,
    output reg input_index,
    output reg y_in,
    output reg y
);

    // Microcode ROM table
    reg [4:0] microcode_rom = 6'd0:0, 1:1, 2:2, 3:3, 4:4, 5:5;

    // Current address in microcode ROM
    reg present_addr = 4'd0;

    // State control signals
    reg action = 0;
    reg [3:0] weight_update = 4'd0;
    reg [3:0] bias_update = 4'd0;
    reg [3:0] target = 4'd0;

    // Initialize weights and bias
    always (posedge clock) begin
        case (present_addr)
            4'd0: begin
                // Action 0: Initialize weights and bias to zero
                percep_w1 = 4'd0;
                percep_w2 = 4'd0;
                percep_bias = 4'd0;
                present_addr = present_addr + 1;
                action = 1;
                continue;
            end

            1: begin
                // Action 1: Compute perceptron output
                y_in = bias + x1 * percep_w1 + x2 * percep_w2;
                y = (y_in >= (threshold + 2)) ? 4'd1 : (y_in <= (threshold - 2) ? 4'd-1 : 4'd0);
                present_addr = present_addr + 1;
                action = 2;
                continue;
            end

            2: begin
                // Action 2: Select target based on gate type and input index
                case (gate_select)
                    2'b00: target = 4'd1;
                    2'b01: target = (x1 == 4'd1) ? 4'd1 : 4'd-1;
                    2'b10: target = (x2 == 4'd1) ? 4'd1 : 4'd-1;
                    2'b11: target = 4'd-1;
                endcase
                present_addr = present_addr + 1;
                action = 3;
                continue;
            end

            3: begin
                // Action 3: Update weights and bias if needed
                if ((y_in > threshold && y != 1) || (y_in < threshold && y != -1)) begin
                    weight_update = learning_rate * x1 * target;
                    weight_update = weight_update & 15;
                    weight_update = (weight_update >> 2) & 3'd1;
                    weight_update = weight_update << 2;
                    
                    weight_update = weight_update & 4'd1;
                    bias_update = learning_rate * target;
                    bias_update = bias_update & 15;
                    bias_update = (bias_update >> 2) & 3'd1;
                    bias_update = bias_update << 2;
                    
                    bias_update = bias_update & 4'd1;
                else
                    weight_update = 4'd0;
                    bias_update = 4'd0;
                end

                percep_w1 = percep_w1 + weight_update;
                percep_w2 = percep_w2 + weight_update;
                percep_bias = percep_bias + bias_update;
                
                present_addr = present_addr + 1;
                action = 4;
                continue;
            end

            4: begin
                // Action 4: Check for convergence
                if (weight_update == 4'd0 && bias_update == 4'd0) begin
                    stop = 1;
                    present_addr = 4'd5;
                    action = 5;
                else
                    present_addr = present_addr + 1;
                    action = 1;
                end
                continue;
            end

            default: begin
                present_addr = present_addr + 1;
                action = 1;
            end
        end
    end

    // Output signals
    output reg [3:0] prev_percep_wt_1 = percep_w1;
    output reg [3:0] prev_percep_wt_2 = percep_w2;
    output reg [3:0] prev_percep_bias = percep_bias;
    output reg input_index = present_addr & 3'd1;
    output reg y_in = y_in;
    output reg y = y;
endmodule