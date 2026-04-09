module perceptron_gates(
    input clock,
    input rst_n,
    input [3:0] x1,
    input [3:0] x2,
    input [1:0] learning_rate,
    input [3:0] threshold,
    input [1:0] gate_select
    output [3:0] percep_w1,
    output [3:0] percep_w2,
    output [3:0] percep_bias,
    output [1:0] stop,
    output [2:0] input_index,
    output [3:0] prev_percep_wt_1,
    output [3:0] prev_percep_wt_2,
    output [3:0] prev_percep_bias
);

    // Microcode ROM definition
    reg [3:0] microcode_rom [6:0];

    // State variable for microcode execution
    reg present_addr;

    // Always block to load initial microcode
    always clock falling edge, rst_n inactive high:
        present_addr = 4'd0;
        microcode_rom[0] = 4'b0000;
        microcode_rom[1] = 4'b0001;
        microcode_rom[2] = 4'b0010;
        microcode_rom[3] = 4'b0011;
        microcode_rom[4] = 4'b0100;
        microcode_rom[5] = 4'b0101;

    // State transition logic
    always clock falling edge:
        if (rst_n) begin
            present_addr = 4'd0;
        else
            present_addr = present_addr + 1;
            if (present_addr >= 6) present_addr = 4'd0;
        end

    // Microcode execution
    always clock falling edge:
        case (present_addr)
            4'd0: begin
                // Action 0: Initialize weights and bias to zero
                percep_w1 = 4'd1;
                percep_w2 = 4'd1;
                percep_bias = 4'd1;
                present_addr = 4'd1;
                // Update previous weights and bias
                prev_percep_wt_1 = percep_w1;
                prev_percep_wt_2 = percep_w2;
                prev_percep_bias = percep_bias;
            end

            4'd1: begin
                // Action 1: Compute perceptron output
                y_in = (x1 & percep_w1) + (x2 & percep_w2) + percep_bias;
                y = y_in > (threshold >> 2) ? 4'd1 : 4'd-1;
                present_addr = 4'd2;
                // Update previous outputs
                prev_percep_wt_1 = y_in;
                prev_percep_wt_2 = y;
                prev_percep_bias = y;
            end

            4'd2: begin
                // Action 2: Select target based on gate type and input index
                case (gate_select)
                    2'b00: target = 4'd1;
                    2'b01: target = (x1 & x2) ? 4'd1 : 4'd-1;
                    2'b10: target = (x1 | x2) ? 4'd1 : 4'd-1;
                    2'b11: target = 4'd-1;
                endcase
                present_addr = 4'd3;
                // Update previous target
                prev_percep_wt_1 = target;
            end

            4'd3: begin
                // Action 3: Update weights and bias if needed
                wt1_update = (y != target) ? (learning_rate & x1) : 4'd0;
                wt2_update = (y != target) ? (learning_rate & x2) : 4'd0;
                bias_update = (y != target) ? learning_rate : 4'd0;
                
                // Apply updates
                percep_w1 = percep_w1 + wt1_update;
                percep_w2 = percep_w2 + wt2_update;
                percep_bias = percep_bias + bias_update;
                
                // Update previous weights and bias
                prev_percep_wt_1 = wt1_update;
                prev_percep_wt_2 = wt2_update;
                prev_percep_bias = bias_update;
                present_addr = 4'd4;
            end

            4'd4: begin
                // Action 4: Check for convergence
                if (wt1_update == 4'd0 && wt2_update == 4'd0 && bias_update == 4'd0) begin
                    stop = 1;
                    present_addr = 4'd5;
                end
                present_addr = 4'd5;
            end

            4'd5: begin
                // Action 5: Finalize updates and prepare next epoch
                percep_w1 = percep_w1 + prev_percep_wt_1;
                percep_w2 = percep_w2 + prev_percep_wt_2;
                percep_bias = percep_bias + prev_percep_bias;
                present_addr = 4'd0;
            end
        end

    // Always block to handle input index
    always clock falling edge:
        if (rst_n) begin
            input_index = 4'd0;
        else
            input_index = input_index + 1;
            if (input_index >= 4) input_index = 4'd0;
        end

endmodule