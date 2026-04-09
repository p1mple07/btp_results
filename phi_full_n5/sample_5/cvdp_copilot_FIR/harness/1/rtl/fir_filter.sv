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
            accumulator <= (sample_delay1 << 16) + (sample_delay2 << 8) + coeff3;
            sample_delay1 <= {sample_delay1[14:0], input_sample};
            sample_delay2 <= {sample_delay2[14:0], sample_delay1};
            sample_delay3 <= {sample_delay3[14:0], sample_delay2};
            output_sample <= accumulator;
        end
    end

endmodule
