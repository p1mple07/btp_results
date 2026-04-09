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
    // Changed window_size to signed to avoid division warnings
    input  logic signed [15:0]           window_size,
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic signed [DATA_WIDTH-1:0] avg_out,
    output logic                         threshold_1,
    output logic                         threshold_2,
    output logic                         sum_ready
);

    // Local parameters to extend threshold values to match the accumulator width
    localparam integer THRESHOLD_EXTEND_1 = DATA_WIDTH + 1 - $bits(THRESHOLD_VALUE_1);
    localparam integer THRESHOLD_EXTEND_2 = DATA_WIDTH + 1 - $bits(THRESHOLD_VALUE_2);

    // Sequential Registers
    logic signed [DATA_WIDTH+1:0] sum_accum;
    logic [15:0]                  sample_count;

    // Combinational Signals
    logic signed [DATA_WIDTH-1:0] weighted_input;
    // Extended version of weighted_input to match sum_accum width
    logic signed [DATA_WIDTH+1:0] weighted_input_ext;
    logic signed [DATA_WIDTH+1:0] new_sum;
    logic                         threshold_1_comb;
    logic                         threshold_2_comb;
    logic                         sum_ready_reg;

    // Combinational Logic
    always_comb begin
        sum_ready_reg = 1'b0;
        // Multiply data_in by WEIGHT (casting WEIGHT to signed to ensure proper multiplication)
        weighted_input = $signed(data_in) * $signed(WEIGHT);
        // Extend weighted_input to match the width of sum_accum
        weighted_input_ext = $signed({{1{1'b0}}, weighted_input});
        new_sum = sum_accum + weighted_input_ext;

        // Extend threshold values to 33 bits (DATA_WIDTH+1)
        threshold_1_comb = (new_sum >= $signed({{THRESHOLD_EXTEND_1{1'b0}}, THRESHOLD_VALUE_1})) ||
                           (new_sum <= $signed({{THRESHOLD_EXTEND_1{1'b0}}, -THRESHOLD_VALUE_1}));
        threshold_2_comb = (new_sum >= $signed({{THRESHOLD_EXTEND_2{1'b0}}, THRESHOLD_VALUE_2})) ||
                           (new_sum <= $signed({{THRESHOLD_EXTEND_2{1'b0}}, -THRESHOLD_VALUE_2}));

        if (data_valid) begin
            if (ACCUM_MODE == 0) begin
                sum_ready_reg = (threshold_1_comb || threshold_2_comb) ? 1'b1 : 1'b0;
            end else if (ACCUM_MODE == 1) begin
                sum_ready_reg = ((sample_count + 1) >= window_size) ? 1'b1 : 1'b0;
            end
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sum_accum     <= '0;
            sample_count  <= 16'd0;
            sum_ready     <= 1'b0;
            sum_out       <= '0;
            avg_out       <= '0;
            threshold_1   <= 1'b0;
            threshold_2   <= 1'b0;
        end else if (data_valid) begin
            threshold_1 <= threshold_1_comb;
            threshold_2 <= threshold_2_comb;

            if (ACCUM_MODE == 1) begin  
                // Accumulate using the extended weighted input
                sum_accum <= sum_accum + $signed({{1{1'b0}}, weighted_input});
                sample_count <= sample_count + 1;
                if (sum_ready_reg) begin
                    // Truncate the 33-bit sum to DATA_WIDTH bits for sum_out
                    sum_out <= (sum_accum + $signed({{1{1'b0}}, weighted_input}))[DATA_WIDTH-1:0];
                    // Perform division after truncation; cast window_size to signed
                    avg_out <= (sum_accum + $signed({{1{1'b0}}, weighted_input}))[DATA_WIDTH-1:0] / $signed(window_size);
                    sum_ready <= 1'b1;
                    sum_accum <= '0;
                    sample_count <= 16'd0;
                end else begin
                    sum_ready <= 1'b0;
                    sum_out   <= '0;
                    avg_out   <= '0;
                end
            end else begin  
                sum_accum <= sum_accum + $signed({{1{1'b0}}, weighted_input});
                if (sum_ready_reg) begin
                    sum_out <= (sum_accum + $signed({{1{1'b0}}, weighted_input}))[DATA_WIDTH-1:0];
                    sum_ready <= 1'b1;
                end else begin
                    sum_ready <= 1'b0;
                    sum_out   <= '0;
                end
                avg_out <= '0; 
            end
        end else begin
            sum_ready <= 1'b0;
        end
    end

endmodule