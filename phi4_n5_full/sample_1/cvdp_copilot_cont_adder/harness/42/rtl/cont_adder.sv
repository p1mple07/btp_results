module cont_adder #(
    parameter DATA_WIDTH = 32,
    parameter signed THRESHOLD_VALUE_1 = 50,
    parameter signed THRESHOLD_VALUE_2 = 100,
    // Removed unused parameter SIGNED_INPUTS
    parameter ACCUM_MODE = 0,
    parameter WEIGHT = 1
) (
    input  logic                         clk,
    input  logic                         reset,
    input  logic signed [DATA_WIDTH-1:0] data_in,
    input  logic                         data_valid,
    input  logic [15:0]                  window_size,
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic signed [DATA_WIDTH-1:0] avg_out,
    output logic                         threshold_1,
    output logic                         threshold_2,
    output logic                         sum_ready
);

    // Sequential Registers
    logic signed [DATA_WIDTH+1:0] sum_accum;
    logic [15:0]                  sample_count;

    // Combinational Signals
    // Note: weighted_input is computed from data_in and WEIGHT.
    // To match the width of sum_accum, we explicitly extend it.
    logic signed [DATA_WIDTH-1:0] weighted_input;
    logic signed [DATA_WIDTH+1:0] weighted_input_ext;
    logic signed [DATA_WIDTH+1:0] new_sum;
    logic                         threshold_1_comb;
    logic                         threshold_2_comb;
    logic                         sum_ready_reg;

    // Combinational Logic
    always_comb begin
        sum_ready_reg = 0;
        // Multiply input by WEIGHT and extend its width to match sum_accum.
        weighted_input = data_in * WEIGHT;
        weighted_input_ext = {2{weighted_input[DATA_WIDTH-1]}, weighted_input};
        new_sum = sum_accum + weighted_input_ext;

        threshold_1_comb = (new_sum >= THRESHOLD_VALUE_1) || (new_sum <= -THRESHOLD_VALUE_1);
        threshold_2_comb = (new_sum >= THRESHOLD_VALUE_2) || (new_sum <= -THRESHOLD_VALUE_2);

        if (data_valid) begin
            if (ACCUM_MODE == 0) begin
                if (threshold_1_comb || threshold_2_comb)
                    sum_ready_reg = 1;
                else
                    sum_ready_reg = 0;
            end else if (ACCUM_MODE == 1) begin
                if ((sample_count + 1) >= window_size)
                    sum_ready_reg = 1;
                else
                    sum_ready_reg = 0;
            end
        end else begin
            sum_ready_reg = 0;
        end
    end

    // Sequential Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sum_accum     <= 0;
            sample_count  <= 0;
            sum_ready     <= 0;
            sum_out       <= 0;
            avg_out       <= 0;
            threshold_1   <= 0;
            threshold_2   <= 0;
        end else if (data_valid) begin
            threshold_1 <= threshold_1_comb;
            threshold_2 <= threshold_2_comb;

            if (ACCUM_MODE == 1) begin  
                // Use the extended weighted input to ensure proper width in arithmetic.
                sum_accum    <= sum_accum + weighted_input_ext;
                sample_count <= sample_count + 1;
                if (sum_ready_reg) begin
                    sum_out      <= sum_accum + weighted_input_ext;
                    // Extend window_size to match the numerator width for division.
                    avg_out      <= (sum_accum + weighted_input_ext) / { {DATA_WIDTH+1{1'b0}}, window_size };
                    sum_ready    <= 1;
                    sum_accum    <= 0;
                    sample_count <= 0;
                end else begin
                    sum_ready <= 0;
                    sum_out   <= 0;
                    avg_out   <= 0;
                end
            end else begin  
                sum_accum <= sum_accum + weighted_input_ext;
                if (sum_ready_reg) begin
                    sum_out   <= sum_accum + weighted_input_ext;
                    sum_ready <= 1;
                end else begin
                    sum_ready <= 0;
                    sum_out   <= 0;
                end
                avg_out <= 0; 
            end
        end else begin
            sum_ready <= 0;
        end
    end

endmodule