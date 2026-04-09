module qam16_demapper_interpolated #(
  parameter N         = 4,  // Number of original mapped symbols (even number ≥ 2)
  parameter OUT_WIDTH = 4,  // Bit width of each output symbol
  parameter IN_WIDTH  = 3   // Bit width of I/Q components (signed)
)(
  input  logic [((N + N/2)*IN_WIDTH)-1:0] I,  // Packed I vector: [Mapped0, Interp0, Mapped1, Mapped2, Interp1, Mapped2, ...]
  input  logic [((N + N/2)*IN_WIDTH)-1:0] Q,  // Packed Q vector with the same organization
  output logic [N*OUT_WIDTH-1:0] bits,         // Demapped bit stream (each symbol is OUT_WIDTH bits)
  output logic error_flag                     // Global error flag (1 if any interpolated sample error detected)
);

  // Predefined error threshold for deviation (can be adjusted as needed)
  localparam int ERROR_THRESHOLD = 1;

  // The input vectors are organized in groups of three segments:
  // For each group i (0 <= i < N/2):
  //   - Mapped sample 0: I[3*i*IN_WIDTH +: IN_WIDTH] and Q[3*i*IN_WIDTH +: IN_WIDTH]
  //   - Interpolated sample: I[(3*i+1)*IN_WIDTH +: IN_WIDTH] and Q[(3*i+1)*IN_WIDTH +: IN_WIDTH]
  //   - Mapped sample 1: I[(3*i+2)*IN_WIDTH +: IN_WIDTH] and Q[(3*i+2)*IN_WIDTH +: IN_WIDTH]
  //
  // The output bits vector is built by concatenating the demapped symbols from each mapped sample.
  // For group i, the first mapped sample forms bits[2*i*OUT_WIDTH +: OUT_WIDTH] and
  // the second mapped sample forms bits[(2*i+1)*OUT_WIDTH +: OUT_WIDTH].

  always_comb begin
    error_flag = 1'b0;
    bits       = '{default: 1'b0};  // initialize output bits to zero

    for (int i = 0; i < N/2; i++) begin
      // Extract signals for group i from I vector
      logic signed [IN_WIDTH-1:0] mapped_I0, interp_I, mapped_I1;
      mapped_I0 = I[3*i*IN_WIDTH +: IN_WIDTH];
      interp_I  = I[(3*i+1)*IN_WIDTH +: IN_WIDTH];
      mapped_I1 = I[(3*i+2)*IN_WIDTH +: IN_WIDTH];

      // Extract signals for group i from Q vector
      logic signed [IN_WIDTH-1:0] mapped_Q0, interp_Q, mapped_Q1;
      mapped_Q0 = Q[3*i*IN_WIDTH +: IN_WIDTH];
      interp_Q  = Q[(3*i+1)*IN_WIDTH +: IN_WIDTH];
      mapped_Q1 = Q[(3*i+2)*IN_WIDTH +: IN_WIDTH];

      // Calculate expected interpolated values using a wider signal (IN_WIDTH+1 bits)
      logic signed [IN_WIDTH:0] sum_I, expected_I;
      sum_I     = {1'b0, mapped_I0} + {1'b0, mapped_I1};
      expected_I = sum_I >>> 1;  // arithmetic right shift by 1

      logic signed [IN_WIDTH:0] sum_Q, expected_Q;
      sum_Q     = {1'b0, mapped_Q0} + {1'b0, mapped_Q1};
      expected_Q = sum_Q >>> 1;

      // Compute absolute difference for I component
      logic signed [IN_WIDTH:0] diff_I_temp;
      diff_I_temp = {1'b0, interp_I} - expected_I;
      logic signed [IN_WIDTH:0] diff_I;
      if (diff_I_temp < 0)
        diff_I = -diff_I_temp;
      else
        diff_I = diff_I_temp;

      // Compute absolute difference for Q component
      logic signed [IN_WIDTH:0] diff_Q_temp;
      diff_Q_temp = {1'b0, interp_Q} - expected_Q;
      logic signed [IN_WIDTH:0] diff_Q;
      if (diff_Q_temp < 0)
        diff_Q = -diff_Q_temp;
      else
        diff_Q = diff_Q_temp;

      // Set error flag if any deviation exceeds the threshold
      if (diff_I >= ERROR_THRESHOLD || diff_Q >= ERROR_THRESHOLD)
        error_flag = 1'b1;

      // Map the mapped I and Q components to 2-bit codes based on the QAM16 constellation:
      // -3 -> 00, -1 -> 01, 1 -> 10, 3 -> 11
      logic [1:0] bits_I0, bits_Q0, bits_I1, bits_Q1;
      case (mapped_I0)
        -3: bits_I0 = 2'b00;
        -1: bits_I0 = 2'b01;
         1: bits_I0 = 2'b10;
         3: bits_I0 = 2'b11;
        default: bits_I0 = 2'bxx;
      endcase
      case (mapped_Q0)
        -3: bits_Q0 = 2'b00;
        -1: bits_Q0 = 2'b01;
         1: bits_Q0 = 2'b10;
         3: bits_Q0 = 2'b11;
        default: bits_Q0 = 2'bxx;
      endcase
      case (mapped_I1)
        -3: bits_I1 = 2'b00;
        -1: bits_I1 = 2'b01;
         1: bits_I1 = 2'b10;
         3: bits_I1 = 2'b11;
        default: bits_I1 = 2'bxx;
      endcase
      case (mapped_Q1)
        -3: bits_Q1 = 2'b00;
        -1: bits_Q1 = 2'b01;
         1: bits_Q1 = 2'b10;
         3: bits_Q1 = 2'b11;
        default: bits_Q1 = 2'bxx;
      endcase

      // Combine the mapped samples into the output bits vector.
      // For group i:
      // - The first mapped sample (from mapped_I0 and mapped_Q0) is placed at bits[2*i*OUT_WIDTH +: OUT_WIDTH].
      // - The second mapped sample (from mapped_I1 and mapped_Q1) is placed at bits[(2*i+1)*OUT_WIDTH +: OUT_WIDTH].
      bits[2*i*OUT_WIDTH +: OUT_WIDTH] = {bits_I0, bits_Q0};
      bits[(2*i+1)*OUT_WIDTH +: OUT_WIDTH] = {bits_I1, bits_Q1};
    end
  end

endmodule