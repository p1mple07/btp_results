module cont_adder #(
    parameter DATA_WIDTH = 32,
    parameter signed THRESHOLD_VALUE_1 = 50,
    parameter signed THRESHOLD_VALUE_2 = 100,
    parameter SIGNED_INPUTS = 1,
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
    output logic signed threshold_1,
    output logic signed threshold_2
);

    // Sequential Registers
    logic signed [DATA_WIDTH+1:0] sum_accum;
    logic [15:0]                  sample_count;

    // Combinational Signals
    logic signed [DATA_WIDTH-1:0] weighted_input;
    logic signed [DATA_WIDTH-1:0] new_sum;
    logic                         threshold_1_comb;
    logic                         threshold_2_comb;
    logic                         sum_ready_reg;

    // Combinational Logic
    always_comb begin
        sum_ready_reg = 0;
        weighted_input = {DATA_WIDTH{data_in[DATA_WIDTH-1]}} * WEIGHT; // Ensure proper bit-wise multiplication
        new_sum = sum_accum + weighted_input;

        threshold_1_comb = (new_sum >= THRESHOLD_VALUE_1) || (new_sum <= -THRESHOLD_VALUE_1);
        threshold_2_comb = (new_sum >= THRESHOLD_VALUE_2) || (new_sum <= -THRESHOLD_VALUE_2);

        if (data_valid) begin
            if (ACCUM_MODE == 0) begin
                if (threshold_1_comb || threshold_2_comb) begin
                    sum_ready_reg = 1;
                end else begin
                    sum_ready_reg = 0;
                end
            end else if (ACCUM_MODE == 1) begin
                if ((sample_count + 1) >= window_size) begin
                    sum_ready_reg = 1;
                end else begin
                    sum_ready_reg = 0;
                end
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
                sum_accum    <= sum_accum + weighted_input;
                sample_count <= sample_count + 1;
                if (sum_ready_reg) begin
                    sum_out      <= sum_accum + weighted_input;
                    avg_out      <= (sum_accum + weighted_input) / {1'b1, WEIGHT - 1'b1}; // Avoid division by zero by adding a small value
                    sum_ready    <= 1;
                    sum_accum    <= 0;
                    sample_count <= 0;
                end else begin
                    sum_ready <= 0;
                    sum_out   <= 0;
                    avg_out   <= 0;
                end
            end else begin  
                sum_accum <= sum_accum + weighted_input;
                if (sum_ready_reg) begin
                    sum_out   <= sum_accum + weighted_input;
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
