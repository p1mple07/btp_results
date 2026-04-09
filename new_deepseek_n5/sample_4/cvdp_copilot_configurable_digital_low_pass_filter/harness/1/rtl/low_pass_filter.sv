module low_pass_filter(
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH * NUM_TAPS - 1:0] data_in,
    input wire valid_in,
    input wire [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs
    ,
    output wire [NBW_MULT + $clog2(NUM_TAPS) - 1:0] data_out,
    output wire valid_out
);

    // Internal signals
    reg [DATA_WIDTH - 1:0] data_reg[NUM_TAPS - 1:0];
    reg [COEFF_WIDTH - 1:0] coeff_reg[NUM_TAPS - 1:0];
    reg [NBW_MULT - 1:0] taps_mult[NUM_TAPS - 1:0];
    reg sum;
    reg [valid_in] valid_reg;

    always @posedge clk begin
        if (reset) begin
            data_reg[:] = 0;
            coeff_reg[:] = 0;
            sum = 0;
            valid_reg = ~valid_in;
        end else begin
            if (valid_in) begin
                data_reg = data_in;
                coeff_reg = coeffs;
                valid_reg = valid_in;
            end
        end

        // Element-wise multiplication and summation
        taps_mult[0] = (data_reg[0] * coeff_reg[0]);
        taps_mult[1] = (data_reg[1] * coeff_reg[1]);
        taps_mult[2] = (data_reg[2] * coeff_reg[2]);
        taps_mult[3] = (data_reg[3] * coeff_reg[3]);
        taps_mult[4] = (data_reg[4] * coeff_reg[4]);
        taps_mult[5] = (data_reg[5] * coeff_reg[5]);
        taps_mult[6] = (data_reg[6] * coeff_reg[6]);
        taps_mult[7] = (data_reg[7] * coeff_reg[7]);

        sum = taps_mult[0] + taps_mult[1] + taps_mult[2] + taps_mult[3] + taps_mult[4] + taps_mult[5] + taps_mult[6] + taps_mult[7];
    end

    // Set valid_out after processing all taps
    valid_out = valid_in & (sum != 0);

endmodule