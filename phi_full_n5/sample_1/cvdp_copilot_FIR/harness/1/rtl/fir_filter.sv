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
            sample_delay1 <= 'b0;
            sample_delay2 <= 'b0;
            sample_delay3 <= 'b0;
            accumulator <= 0;
            output_sample <= 'b0;
        end else begin
            // Regular operation: Shift samples, compute filtered output
            sample_delay1 <= input_sample;
            sample_delay2 <= sample_delay1;
            sample_delay3 <= sample_delay2;

            // Perform FIR filtering logic
            accumulator <= (accumulator << 1) | (coeff0 * sample_delay1) |
                           (coeff1 * sample_delay2) | (coeff2 * sample_delay3) |
                           (coeff3 * input_sample);

            // Ensure output is 4 cycles delayed
            if (clk_counter == 4) begin
                output_sample <= accumulator >> 1; // Divide by 2 for signed 16-bit result
                clk_counter <= 0; // Reset counter
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end

endmodule
