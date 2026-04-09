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
            sample_delay1 <= 0;
            sample_delay2 <= 0;
            sample_delay3 <= 0;
            accumulator <= 0;
            output_sample <= 0;
        end else begin
            // Regular operation: Shift samples, compute filtered output
            sample_delay3 <= sample_delay2;
            sample_delay2 <= sample_delay1;
            sample_delay1 <= input_sample;

            accumulator <= accumulator + ((coeff0 * sample_delay1) + (coeff1 * sample_delay2) + (coeff2 * sample_delay3));
            output_sample <= $signed(accumulator[15:0]);
        end
    end

endmodule