module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input  logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

  // Optimized combinational logic: compute output indices on the fly,
  // eliminating intermediate arrays and reducing wiring significantly.
  always_comb begin
    for (int j = 0; j < 256; j++) begin
      if (j < 128) begin
         // For j in [0,127]:
         //   Let q = j/16 and r = j % 16.
         //   r_prime = (r - 2*q) mod 16, c_prime = (r - q) mod 16.
         int q = j / 16;
         int r = j % 16;
         int row = (r + 16 - (2 * q)) % 16;  // Ensures non-negative result
         int col = (r + 16 - q) % 16;
         out_data[j] = in_data[(row * 16) + col];
      end else begin
         // For j in [128,255]:
         //   Let q = j/16 and r = j % 16.
         //   r_prime = (r - 1 - 2*q) mod 16, c_prime = (r - 1 - q) mod 16.
         int q = j / 16;
         int r = j % 16;
         int row = (r + 16 - 1 - (2 * q)) % 16;
         int col = (r + 16 - 1 - q) % 16;
         out_data[j] = in_data[(row * 16) + col];
      end
    end
  end

endmodule