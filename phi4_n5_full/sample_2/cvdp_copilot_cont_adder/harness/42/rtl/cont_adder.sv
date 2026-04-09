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
    // Note: weighted_input is now declared with the same width as sum_accum
    // to avoid width expansion/truncation warnings.
    logic signed [DATA_WIDTH+1:0] weighted_input;
    logic signed [DATA_WIDTH+1:0] new_sum;
    logic                         threshold_1_comb;
    logic                         threshold_2_comb;
    logic                         sum_ready_reg;

    // Combinational Logic
    always_comb begin
        sum_ready_reg = 0;
        // Explicitly sign-extend data_in to DATA_WIDTH+1 bits before multiplication.
        weighted_input = {data_in[DATA_WIDTH-1], data_in} * $signed(WEIGHT);
        new_sum = sum_accum + weighted_input;

        threshold_1_comb = (new_sum >= THRESHOLD_VALUE_1) || (new_sum <= -THRESHOLD_VALUE_1);
        threshold_2_comb = (new_sum >= THRESHOLD_VALUE_2) || (new_sum <= -THRESHOLD_VALUE_2);

        if (data_valid) begin
            if (ACCUM_MODE == 0) begin
                sum_ready_reg = (threshold_1_comb || threshold_2_comb) ? 1 : 0;
            end else if (ACCUM_MODE == 1) begin
                sum_ready_reg = ((sample_count + 1) >= window_size) ? 1 : 0;
            end
        end else begin
            sum_ready_reg = 0;
        end
    end

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
                logic signed [DATA_WIDTH+1:0] new_sum_ff;
                new_sum_ff = sum_accum + weighted_input;
                sum_accum <= new_sum_ff;
                sample_count <= sample_count + 1;
                if (sum_ready_reg) begin
                    sum_out <= new_sum_ff;
                    avg_out <= new_sum_ff / $signed(window_size);
                    sum_ready <= 1;
                    sum_accum <= 0;
                    sample_count <= 0;
                end else begin
                    sum_ready <= 0;
                    sum_out   <= 0;
                    avg_out   <= 0;
                end
            end else begin  
                logic signed [DATA_WIDTH+1:0] new_sum_ff;
                new_sum_ff = sum_accum + weighted_input;
                sum_accum <= new_sum_ff;
                if (sum_ready_reg) begin
                    sum_out <= new_sum_ff;
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