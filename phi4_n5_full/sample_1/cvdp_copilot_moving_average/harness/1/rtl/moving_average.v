module moving_average (
    input  wire         clk,
    input  wire         reset,
    input  wire [11:0]  data_in,
    output reg  [11:0]  data_out
);

    // Internal buffer to store up to 8 samples (12-bit each)
    reg [11:0] buffer [0:7];
    // Sum register: 16 bits is sufficient since max sum = 8 * 4095 = 32760
    reg [15:0] sum;
    // Counter to track the number of valid samples received
    reg [2:0] sample_count;
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            // Synchronous reset: clear sum, counter, buffer, and output
            sum          <= 16'd0;
            sample_count <= 3'd0;
            data_out     <= 12'd0;
            for (i = 0; i < 8; i = i + 1) begin
                buffer[i] <= 12'd0;
            end
        end else begin
            if (sample_count < 8) begin
                // Accumulate the new sample into the buffer and update the sum
                sum          <= sum + data_in;
                buffer[sample_count] <= data_in;
                sample_count <= sample_count + 1;
                // Compute the moving average by dividing the sum by 8 (as specified)
                data_out <= sum >> 3;  // equivalent to integer division by 8
            end else begin
                // Buffer is full; perform a circular shift:
                // Save the oldest sample before it is overwritten
                reg [11:0] oldest;
                oldest = buffer[0];
                // Shift the buffer: move each sample one position to the right
                for (i = 7; i > 0; i = i - 1) begin
                    buffer[i] <= buffer[i-1];
                end
                // Store the new sample at the beginning of the buffer
                buffer[0] <= data_in;
                // Update the sum by subtracting the oldest sample and adding the new one
                sum <= sum - oldest + data_in;
                // Compute the moving average (integer division by 8)
                data_out <= sum >> 3;
            end
        end
    end

endmodule