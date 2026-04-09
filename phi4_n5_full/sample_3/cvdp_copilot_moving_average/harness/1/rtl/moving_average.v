module moving_average (
    input         clk,
    input         reset,
    input  [11:0] data_in,
    output reg [11:0] data_out
);

  // Circular buffer to hold the last 8 samples
  reg [11:0] buffer [0:7];
  // 3-bit pointer to index into the 8-element buffer
  reg [2:0] pointer;
  // 16-bit register to accumulate the sum of the samples in the buffer
  reg [15:0] sum;
  // 4-bit counter for the number of samples stored (max 8)
  reg [3:0] count;
  // Temporary register to hold the old value being replaced
  reg [11:0] old_val;

  always @(posedge clk) begin
    if (reset) begin
      // On reset: clear the pointer, counter, sum, and output.
      pointer <= 0;
      count   <= 0;
      sum     <= 0;
      data_out<= 0;
      // Clear the circular buffer
      integer i;
      for (i = 0; i < 8; i = i + 1)
        buffer[i] <= 0;
    end else begin
      // Read the value currently at the buffer location pointed to by 'pointer'
      old_val = buffer[pointer];
      // Store the new incoming sample into the buffer at the current pointer
      buffer[pointer] <= data_in;
      // Update the running sum: add the new sample and subtract the old sample
      sum <= sum + data_in - old_val;
      // If the buffer is not yet full, increment the sample count
      if (count < 8)
        count <= count + 1;
      // Update the pointer in a circular fashion (0 to 7)
      pointer <= (pointer + 1) % 8;
      // Compute the moving average:
      // For the first (count < 8) samples, average the sum of the available samples.
      // Once 8 samples are stored, always average over 8 samples.
      if (count < 8)
        data_out <= sum / count;
      else
        data_out <= sum / 8;
    end
  end

endmodule