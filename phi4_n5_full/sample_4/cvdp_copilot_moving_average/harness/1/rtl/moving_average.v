module

module moving_average (
    input  wire         clk,
    input  wire         reset,
    input  wire [11:0]  data_in,
    output reg  [11:0]  data_out
);

    // Circular buffer to store up to 8 samples
    reg [11:0] buffer [0:7];
    // Pointer for the circular buffer (indices 0 to 7)
    reg [2:0]  ptr;
    // Number of samples currently stored (0 to 8)
    reg [2:0]  count;
    // Sum register for the last samples (16 bits to cover max sum: 8*4095 = 32760)
    reg [15:0] sum_reg;

    always @(posedge clk) begin
        if (reset) begin
            // Synchronous reset: clear buffer, pointer, count, sum, and output
            count      <= 0;
            ptr        <= 0;
            sum_reg    <= 0;
            data_out   <= 12'b0;
        end else begin
            if (count == 0) begin
                // First sample after reset
                buffer[ptr] <= data_in;
                sum_reg     <= data_in;
                count       <= 1;
                ptr         <= ptr + 1;  // Advance pointer to next index
            end else begin
                // Update sum: subtract oldest sample and add new sample
                sum_reg <= sum_reg - buffer[ptr] + data_in;
                // Store new sample into the buffer at current pointer
                buffer[ptr] <= data_in;
                // Update pointer in a circular fashion (0 to 7)
                ptr <= (ptr + 1) % 8;
                // Increment count until the buffer holds 8 samples
                if (count < 8)
                    count <= count + 1;
            end

            // Compute moving average:
            // For fewer than 8 samples, average over the available samples (sum/count).
            // Once 8 samples are available, always average over the last 8 (sum/8).
            if (count < 8)
                data_out <= sum_reg / count;
            else
                data_out <= sum_reg >> 3;  // Equivalent to integer division by 8
        end
    end

endmodule