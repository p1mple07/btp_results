module moving_average (
    input clock,
    input reset,
    input [11:0] data_in,
    output [11:0] data_out
) {
    // FIFO buffer to store last 8 samples
    reg [11:0] buffer[8];
    // Sum register to accumulate the sum of samples
    reg sum = 0;
    // Number of valid samples in buffer
    reg sample_count = 0;
    // Oldest sample to shift out
    reg oldest_sample = 0;
    
    // Only compute average when buffer is full
    reg average_valid = 0;
    
    // Clock enable
    always clock_edge #1 begin
        if (reset) begin
            // Reset all signals on assertion
            buffer = 8 * {11'h0}; // Clear buffer
            sum = 0; // Reset sum
            sample_count = 0; // Reset sample count
            oldest_sample = 0; // Reset oldest sample
            data_out = 0; // Reset output
        end else begin
            // Shift oldest sample out and new sample in
            oldest_sample = buffer[0];
            buffer[0] = data_in;
            // Update sum
            sum = sum + oldest_sample;
            // Increment sample count
            sample_count = sample_count + 1;
            // If buffer is full, compute average
            if (sample_count >= 8) begin
                average_valid = 1;
                data_out = sum >> 3; // Integer division by 8
            end
        end
    end
}