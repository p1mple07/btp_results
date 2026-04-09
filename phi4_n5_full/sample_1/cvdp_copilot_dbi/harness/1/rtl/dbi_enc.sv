module dbi_enc (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [39:0]  data_in,
  output logic [39:0]  data_out,
  output logic [1:0]   dbi_cntrl
);

  // Register to hold previous data for comparison
  logic [39:0] prev_data;

  // Function to count the number of ones in a 20-bit vector
  function automatic int count_ones(input logic [19:0] value);
    int count;
    begin
      count = 0;
      for (int i = 0; i < 20; i++) begin
         if (value[i])
           count++;
      end
      count_ones = count;
    end
  endfunction

  // Internal signals for splitting data into groups and computing differences
  logic [19:0] group1, group0;          // Current groups from data_in
  logic [19:0] prev_group1, prev_group0; // Previous groups from prev_data
  logic [19:0] diff1, diff0;             // Difference between current and previous groups
  logic [19:0] group1_out, group0_out;   // Output groups after potential inversion

  // Sequential logic: process on rising edge of clk or asynchronous reset
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset: clear outputs and previous data
      data_out   <= 40'b0;
      dbi_cntrl  <= 2'b00;
      prev_data  <= 40'b0;
    end else begin
      // Split the 40-bit input into two 20-bit groups
      group1 = data_in[39:20];
      group0 = data_in[19:0];

      // Extract previous groups from stored previous data
      prev_group1 = prev_data[39:20];
      prev_group0 = prev_data[19:0];

      // Compute the bitwise differences between current and previous groups
      diff1 = group1 ^ prev_group1;
      diff0 = group0 ^ prev_group0;

      // Determine control bits: if more than 10 bits differ, set control bit to 1
      if (count_ones(diff1) > 10)
        dbi_cntrl[1] = 1'b1;
      else
        dbi_cntrl[1] = 1'b0;

      if (count_ones(diff0) > 10)
        dbi_cntrl[0] = 1'b1;
      else
        dbi_cntrl[0] = 1'b0;

      // Generate output groups: invert if control bit is high, pass through if low
      if (dbi_cntrl[1])
        group1_out = ~group1;
      else
        group1_out = group1;

      if (dbi_cntrl[0])
        group0_out = ~group0;
      else
        group0_out = group0;

      // Combine the two groups to form the 40-bit data_out
      data_out <= {group1_out, group0_out};

      // Update previous data with the current cycle's encoded output
      prev_data <= data_out;
    end
  end

endmodule