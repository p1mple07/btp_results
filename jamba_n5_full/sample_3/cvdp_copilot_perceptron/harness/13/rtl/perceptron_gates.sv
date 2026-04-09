module perceptron_gates (
    input  logic clk,
    input  logic rst_n,
    input  logic signed [3:0] x1,
    input  logic signed [3:0] x2,
    input  logic learning_rate,
    input  logic signed [3:0] threshold,
    input  logic [1:0] gate_select,
    output logic signed [3:0] percep_w1,
    output logic signed [3:0] percep_w2,
    output logic signed [3:0] percep_bias,
    output logic [3:0] present_addr,
    output logic stop,
    output logic [2:0] input_index,
    output logic signed [3:0] y_in,
    output logic signed [3:0] y,
    output logic signed [3:0] prev_percep_wt_1,
    output logic signed [3:0] prev_percep_wt_2,
    output logic signed [3:0] prev_percep_bias
);

    logic [7:0] microcode_rom [0:5];
    logic [3:0]  next_addr;
    logic [3:0]  train_action;
    logic [3:0]  microcode_addr;
    logic [15:0] microinstruction;
    logic signed [3:0] t1, t2, t3, t4;

    // Initialise ROM contents
    microcode_rom[0] = 8'b0001_0000;
    microcode_rom[1] = 8'b0010_0001;
    microcode_rom[2] = 8'b0011_0010;
    microcode_rom[3] = 8'b0100_0011;
    microcode_rom[4] = 8'b0101_0100;
    microcode_rom[5] = 8'b0000_0101;

    // Always block for clock and reset handling
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            present_addr <= 4'd0;
            microcode_addr <= 4'd0;
            perceive_wt_1_reg <= 4'd0;
            perceive_wt_2_reg <= 4'd0;
            perceive_bias_reg <= 4'd0;
            input_index <= 2'd0;
            stop <= 1'b0;
        end else begin
            present_addr <= next_addr;
            microcode_addr <= present_addr;
        end
    end

    // Always block for microcode ROM access
    always_comb begin
        microinstruction = microcode_rom[microcode_addr];
        next_addr        = microinstruction[7:4];
        train_action     = microinstruction[3:0];
    end

    // Assign current address to next_addr for the next cycle
    assign present_addr = next_addr + 4'd1;

    // Perceptron weight and bias registers
    logic signed [3:0] percep_wt_1_reg, percep_wt_2_reg, percep_bias_reg;

    // Read ROM data for current microcode address
    always_comb begin
        percep_wt_1_reg  = perceive_wt_1_reg;
        percep_wt_2_reg  = perceive_wt_2_reg;
        percep_bias_reg   = perceive_bias_reg;
    end

    // Compute the perceptron output
    always_comb begin
        y_in = percep_bias_reg + (x1 * percep_wt_1_reg) + (x2 * percep_wt_2_reg);

        // Step 5: apply learning rule
        if (y_in > threshold) begin
            percep_w1  = percep_w1 + learning_rate * x1 * target;
            percep_w2  = percep_w2 + learning_rate * x2 * target;
            percep_bias = percep_bias + learning_rate * target;
        end else if (y_in >= -threshold && y_in <= threshold) begin
            percep_w1  = percep_w1 + learning_rate * x1 * target;
            percep_w2  = percep_w2 + learning_rate * x2 * target;
            percep_bias = percep_bias + learning_rate * target;
        end else begin
            percep_w1  = percep_w1;
            percep_w2  = percep_w2;
            percep_bias = percep_bias;
        end

        // Step 6: check for weight changes
        if (wt1_update != prev_wt1_update || wt2_update != prev_wt2_update || bias_update != prev_bias_update) begin
            stop <= 1'b1;
            next_addr <= 4'd0;
            microcode_addr <= 4'd5;
        end else begin
            stop <= 1'b0;
            next_addr <= next_addr + 4'd1;
            microcode_addr <= 4'd1;
        end
    end

endmodule
