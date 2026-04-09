module dbi_enc (
    input  logic [39:0] data_in,
    input  logic        clk,
    input  logic        rst_n,
    output logic [39:0] data_out,
    output logic [1:0]  dbi_cntrl
);

  // Internal register to store previous data for comparison
  logic [39:0] prev_data;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prev_data <= 40'b0;
      data_out  <= 40'b0;
      dbi_cntrl <= 2'b00;
    end else begin
      // Split data_in into two 20-bit groups:
      // Group-1: MSBs (bits [39:20])
      // Group-0: LSBs (bits [19:0])
      logic [19:0] group1, group0;
      group1 = data_in[39:20];
      group0 = data_in[19:0];

      // Count bit differences between current groups and previous data.
      // For each bit position, compare group1 with prev_data[39:20] and group0 with prev_data[19:0].
      integer i;
      logic [20:0] diff1, diff0;
      diff1 = 0;
      diff0 = 0;
      for (i = 0; i < 20; i = i + 1) begin
        diff1 += group1[i] ^ prev_data[20+i];
        diff0 += group0[i] ^ prev_data[i];
      end

      // Generate control signals:
      // If more than 10 bits differ, set the corresponding control bit to 1.
      logic control1, control0;
      control1 = (diff1 > 10);
      control0 = (diff0 > 10);

      // Generate new data_out based on control signals:
      // For Group-1 (MSBs): if control1 is high, invert the bits; otherwise, pass through unchanged.
      // For Group-0 (LSBs): if control0 is high, invert the bits; otherwise, pass through unchanged.
      logic [39:0] new_data;
      if (control1)
        new_data[39:20] = ~group1;
      else
        new_data[39:20] = group1;
      if (control0)
        new_data[19:0] = ~group0;
      else
        new_data[19:0] = group0;

      // Update outputs and previous data register:
      // The new data_out becomes the "previous data" for the next operation.
      data_out  <= new_data;
      prev_data <= new_data;
      dbi_cntrl <= {control1, control0};
    end
  end

endmodule