module low_pass_filter(
    input wire clock,
    input wire reset,
    input wire [DATA_WIDTH * NUM_TAPS - 1:0] data_in,
    input wire valid_in,
    input wire [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs
    ,
    output wire [NBW_MULT + $clog2(NUM_TAPS) - 1:0] data_out,
    output wire valid_out
);

    // Internal signals
    reg [DATA_WIDTH - 1:0] data_FIFO [NUM_TAPS - 1:0];
    reg [COEFF_WIDTH - 1:0] coeff_FIFO [NUM_TAPS - 1:0];
    reg [NBW_MULT - 1:0] mult_result [NUM_TAPS - 1:0];
    reg [NBW_MULT - 1:0] sum_result;
    reg [NBW_MULT - 1:0] data_out_reg;
    reg valid_FIFO_in, valid_sum_in;

    always_comb begin
        // Store input data and coeffs
        if (valid_in) begin
            data_FIFO = {data_in >> (NUM_TAPS - 1 - $index($i))};
            coeff_FIFO = coeffs >> ($i);
            valid_FIFO_in = 1;
        end else begin
            data_FIFO = data_FIFO - data_FIFO;
            coeff_FIFO = coeff_FIFO - coeff_FIFO;
            valid_FIFO_in = 0;
        end

        // Element-wise multiplication
        for ($i = 0; $i < NUM_TAPS; $i++) begin
            mult_result[$i] = data_FIFO[$i] * coeff_FIFO[$i];
        end

        // Summation
        sum_result = 0;
        for ($i = 0; $i < NUM_TAPS; $i++) begin
            sum_result = sum_result + mult_result[$i];
        end
        data_out_reg = sum_result;

        // Output
        data_out = data_out_reg;
        valid_out = valid_FIFO_in;
    end

    // Reset handling
    always begin
        if (reset) begin
            data_FIFO = {0};
            coeff_FIFO = {0};
            sum_result = 0;
            data_out_reg = 0;
            valid_out = 0;
        end
    end
endmodule