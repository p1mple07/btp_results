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

// Instantiation of the pre‑defined microcode ROM
localparam struct {
    logic [7:0] next_addr;
    logic [3:0] train_action;
} microcode_rom [0:5] = {
    8'b0001_0000,   // 0 – initialise weights and bias to zero
    8'b0010_0001,   // 1 – compute y_in
    8'b0011_0010,   // 2 – compute y
    8'b0100_0011,   // 3 – check y vs target
    8'b0101_0100,   // 4 – update weights
    8'b0000_0101   // 5 – increment and go to next
};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        present_addr <= 4'd0;
        microcode_addr <= 4'd0;
        percep_wt_1_reg <= 4'd0;
        percep_wt_2_reg <= 4'd0;
        percep_bias_reg <= 4'd0;
        input_index <= 2'd0;
        stop <= 1'b0;
    end else begin
        present_addr <= next_addr;
        microcode_addr <= present_addr;
    end
end

always_comb begin
    microinstruction = microcode_rom[microcode_addr];
    next_addr        = microinstruction[7:4];
    train_action     = microinstruction[3:0];
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        present_addr    <= 4'd0;
        microcode_addr  <= 4'd0;
        percep_wt_1_reg <= 4'd0;
        percep_wt_2_reg <= 4'd0;
        percep_bias_reg <= 4'd0;
        input_index     <= 2'd0;
        stop            <= 1'b0;
    end else begin
        present_addr    <= next_addr;
        microcode_addr  <= present_addr;
    end
end

always_comb begin
    assign percep_w1 = percep_wt_1_reg;
    assign percep_w2 = percep_wt_2_reg;
    assign percep_bias = percep_bias_reg;
end

always_comb begin
    if (train_action == 4'd0) begin
        // Initialise weights and bias
        percep_wt_1_reg <= 4'd0;
        percep_wt_2_reg <= 4'd0;
        percep_bias_reg <= 4'd0;
        input_index <= 2'd0;
        stop <= 1'b0;
    end else if (train_action == 4'd1) begin
        // Compute perceptron output
        y_in = percep_bias_reg + (x1 * percep_wt_1_reg) + (x2 * percep_wt_2_reg);
        // Update weights
        if (y_in > threshold)
            y = 4'd1;
        else if (y_in >= -threshold && y_in <= threshold)
            y = 4'd0;
        else
            y = -4'd1;

        wt1_update = learning_rate * x1 * target;
        wt2_update = learning_rate * x2 * target;
        bias_update = learning_rate * target;

        wt1_update = 0;
        wt2_update = 0;
        bias_update = 0;

        wt1_update = learning_rate * x1 * target;
        wt2_update = learning_rate * x2 * target;
        bias_update = learning_rate * target;
    end else if (train_action == 4'd2) begin
        // Select target value
        if (input_index == 0)
            target = t1;
        else if (input_index == 1)
            target = t2;
        else if (input_index == 2)
            target = t3;
        else if (input_index == 3)
            target = t4;
        else begin
            input_index = 0;
            target = 0;
        end

        // No weight or bias changes
        wt1_update = 0;
        wt2_update = 0;
        bias_update = 0;
    end else if (train_action == 4'd3) begin
        // Compare weighted sum with target
        if (y != target) begin
            wt1_update = learning_rate * x1 * target;
            wt2_update = learning_rate * x2 * target;
            bias_update = learning_rate * target;
        end else begin
            wt1_update = 0;
            wt2_update = 0;
            bias_update = 0;
        end

        // No changes
        wt1_update = 0;
        wt2_update = 0;
        bias_update = 0;
    end else if (train_action == 4'd4) begin
        // Check if weights/bias have changed
        if (wt1_update == prev_wt1_update && wt2_update == prev_wt2_update && bias_update == prev_bias_update)
            stop <= 1'b1;
        else
            stop <= 1'b0;

        // No further changes
        wt1_update <= 0;
        wt2_update <= 0;
        bias_update <= 0;
    end else if (train_action == 4'd5) begin
        // Increment the input index and loop
        input_index <= input_index + 1;
        next_addr <= 4'd0;
    end
end

endmodule
