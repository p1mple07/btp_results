module moving_average (
    input         clk,
    input         reset,
    input  [11:0] data_in,
    output reg [11:0] data_out
);

  // Internal registers
  reg [15:0] sum;      // 16-bit sum to accommodate 8 x 12-bit values
  reg [2:0]  count;    // Number of samples received since last reset (max 8)
  reg [2:0]  index;    // Circular buffer index
  reg [11:0] buffer [0:7];  // Memory buffer for the last 8 samples

  always @(posedge clk) begin
    if (reset) begin
      // Synchronous reset: clear all registers and the buffer
      sum     <= 16'd0;
      count   <= 3'd0;
      index   <= 3'd0;
      data_out<= 12'd0;
      integer i;
      for (i = 0; i < 8; i = i + 1) begin
        buffer[i] <= 12'd0;
      end
    end
    else begin
      if (count < 8) begin
        // Buffer not yet full: add new sample and store it
        sum     <= sum + data_in;
        buffer[count] <= data_in;
        count   <= count + 1;
      end
      else begin
        // Buffer is full: update sum by subtracting oldest sample and adding new one
        sum     <= sum - buffer[index] + data_in;
        buffer[index] <= data_in;
        index   <= index + 1;
      end
      // Compute moving average as sum divided by 8 (via right shift by 3)
      // The result is then truncated to 12 bits.
      data_out <= (sum >> 3)[11:0];
    end
  end

endmodule