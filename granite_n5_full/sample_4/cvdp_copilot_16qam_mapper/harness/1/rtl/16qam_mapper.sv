module qam16_mapper_interpolated #(
  parameter int unsigned N = 4, // Number of input symbols
  parameter int unsigned IN_WIDTH = 4, // Bit width of each input symbol
  parameter int unsigned OUT_WIDTH = 3 // Bit width of the output components
) (
  input logic [N * IN_WIDTH - 1:0] bits, // Packed input bits
  output logic [(N + N / 2) * OUT_WIDTH - 1:0] I, // Packed output of real (I) components
  output logic [(N + N / 2) * OUT_WIDTH - 1:0] Q // Packed output of imaginary (Q) components
);

  localparam int unsigned INTERPOLATED_WIDTH = OUT_WIDTH + 1; // Output bit width for interpolated samples

  always_comb begin
    for (int i = 0; i < N; i++) begin
      int j = i * IN_WIDTH +: INTERPOLATED_WIDTH;

      // Map MSBs to I and LSBs to Q
      if (i % 2 == 0) begin
        I[j +: OUT_WIDTH] = bits[i * IN_WIDTH +: 2];
        Q[j +: OUT_WIDTH] = bits[i * IN_WIDTH + 2 +: 2];
      end else begin
        I[j +: OUT_WIDTH] = bits[i * IN_WIDTH + 1 +: 2];
        Q[j +: OUT_WIDTH] = bits[i * IN_WIDTH + 3 +: 2];
      end

      // Compute interpolated values for I and Q
      if (i > 0 && i < N - 1) begin
        int k = (i - 1) * IN_WIDTH +: INTERPOLATED_WIDTH;

        // Interpolated I
        I[k + OUT_WIDTH] = $signed(I[j + OUT_WIDTH]) + $signed(I[j + OUT_WIDTH - INTERPOLATED_WIDTH]);
        I[k + OUT_WIDTH + 1] = 1'b0;

        // Interpolated Q
        Q[k + OUT_WIDTH] = $signed(Q[j + OUT_WIDTH]) + $signed(Q[j + OUT_WIDTH - INTERPOLATED_WIDTH]);
        Q[k + OUT_WIDTH + 1] = 1'b0;
      end
    end
  end

endmodule