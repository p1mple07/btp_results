module fir_filter (
    input logic clk,
    input logic reset,
    input logic signed [15:0] input_sample,
    output logic signed [15:0] output_sample,
    input logic signed [15:0] coeff0,
    input logic signed [15:0] coeff1,
    input logic signed [15:0] coeff2,
    input logic signed [15:0] coeff3
);

    logic signed [15:0] sample_delay1, sample_delay2, sample_delay3;
    logic signed [31:0] accumulator;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sample_delay1 <= 0;
            sample_delay2 <= 0;
            sample_delay3 <= 0;
            accumulator <= 0;
        end else begin
            sample_delay1 <= input_sample;
            sample_delay2 <= sample_delay1;
            sample_delay3 <= sample_delay2;

            accumulator = (coeff0 * input_sample) +
                           (coeff1 * sample_delay1) +
                           (coeff2 * sample_delay2) +
                           (coeff3 * sample_delay3);
        end
    end

    assign output_sample = accumulator;
endmodule
