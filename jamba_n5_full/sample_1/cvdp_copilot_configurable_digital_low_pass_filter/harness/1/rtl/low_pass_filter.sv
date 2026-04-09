module low_pass_filter #(
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16,
    parameter NUM_TAPS = 8
)(
    input  clk,
    input  reset,
    input  [DATA_WIDTH-1:0] data_in,
    input  [COEFF_WIDTH-1:0] coeffs,
    input  valid_in,
    output reg [NBW_MULT + $clog2(NUM_TAPS) - 1:0] data_out,
    output bit valid_out
);

    // Internal signals
    reg [DATA_WIDTH*NUM_TAPS:0] internal_data;
    reg [COEFF_WIDTH*NUM_TAPS:0] internal_coeffs;
    reg [DATA_WIDTH + COEFF_WIDTH - 1:0] internal_result;
    reg valid_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_out_reg <= 1'b0;
            internal_data <= 0;
            internal_coeffs <= 0;
            internal_result <= 0;
        end else begin
            valid_out_reg <= valid_in;
            internal_data = data_in;
            internal_coeffs = coeffs;
            internal_result = multiply_vector(internal_data, internal_coeffs);
            data_out = internal_result[NBW_MULT-1:0];
            valid_out = (data_out != 0);
        end
    end

endmodule
