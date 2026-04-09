module fir_filter (
    input logic clk,                 // Clock signal
    input logic reset,               // Reset signal
    input logic signed [15:0] input_sample,  // Input data sample
    output logic signed [15:0] output_sample, // Output filtered sample
    input logic signed [15:0] coeff0, // Coefficient for current input sample
    input logic signed [15:0] coeff1, // Coefficient for first delay
    input logic signed [15:0] coeff2, // Coefficient for second delay
    input logic signed [15:0] coeff3  // Coefficient for third delay
);

    // Declare internal storage for delay elements and accumulation
    logic signed [15:0] sample_delay1, sample_delay2, sample_delay3;
    logic signed [31:0] accumulator;

    // Sequential block to handle operations on clock or reset
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset state: Clear all registers and output
            sample_delay1 <= 'bx;
            sample_delay2 <= 'bx;
            sample_delay3 <= 'bx;
            accumulator <= 'bx;
            output_sample <= 'bx;
        end else begin
            // Regular operation: Shift samples, compute filtered output
            sample_delay1 <= input_sample;
            accumulator <= accumulator << 1;
            accumulator <= accumulator + (input_sample * coeff0);

            sample_delay2 <= sample_delay1;
            accumulator <= accumulator << 1;
            accumulator <= accumulator + (sample_delay1 * coeff1);

            sample_delay3 <= sample_delay2;
            accumulator <= accumulator << 1;
            accumulator <= accumulator + (sample_delay2 * coeff2);

            output_sample <= accumulator;

            // Ensure output_sample is 4 clock cycles delayed
            output_sample <= (output_sample << 1) & {output_sample{31{1'b0}}};
        end
    end

endmodule
