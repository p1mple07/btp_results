module fir_filter (
    input  logic                 clk,      // Clock signal
    input  logic                 reset,    // Asynchronous, active-high reset
    input  logic signed [15:0]   input_sample,  // Input data sample
    output logic signed [15:0]   output_sample, // Output filtered sample
    input  logic signed [15:0]   coeff0,   // Coefficient for current input sample
    input  logic signed [15:0]   coeff1,   // Coefficient for first delay element
    input  logic signed [15:0]   coeff2,   // Coefficient for second delay element
    input  logic signed [15:0]   coeff3    // Coefficient for third delay element
);

    // Internal registers for delay elements and accumulation
    logic signed [15:0] sample_delay1;
    logic signed [15:0] sample_delay2;
    logic signed [15:0] sample_delay3;
    logic signed [31:0] accumulator;

    // Pipeline registers to achieve 4-cycle latency (3 stages)
    logic signed [31:0] pipe0;
    logic signed [31:0] pipe1;
    logic signed [31:0] pipe2;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers and output
            sample_delay1 <= 16'sb0;
            sample_delay2 <= 16'sb0;
            sample_delay3 <= 16'sb0;
            accumulator  <= 32'sb0;
            pipe0        <= 32'sb0;
            pipe1        <= 32'sb0;
            pipe2        <= 32'sb0;
            output_sample<= 16'sb0;
        end else begin
            // Shift delay registers: new sample enters sample_delay1
            sample_delay3 <= sample_delay2;
            sample_delay2 <= sample_delay1;
            sample_delay1 <= input_sample;
            
            // Compute the accumulated sum of products
            accumulator <= (coeff0 * input_sample) +
                           (coeff1 * sample_delay1) +
                           (coeff2 * sample_delay2) +
                           (coeff3 * sample_delay3);
            
            // Pipeline the accumulator result to introduce a 4-cycle latency
            pipe0 <= accumulator;
            pipe1 <= pipe0;
            pipe2 <= pipe1;
            
            // Assign the lower 16 bits of the pipelined result to the output sample
            output_sample <= pipe2[15:0];
        end
    end

endmodule