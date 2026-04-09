module qam16_mapper_interpolated #(
  parameter int N       = 4,  // Number of input symbols (≥2 and even)
  parameter int IN_WIDTH = 4,  // Fixed width of each input symbol (4 bits)
  parameter int OUT_WIDTH = 3   // Fixed width of each output component (3 bits)
)(
  input  logic [N*IN_WIDTH-1:0] bits,
  output logic [(3*N/2)*OUT_WIDTH-1:0] I,
  output logic [(3*N/2)*OUT_WIDTH-1:0] Q
);

  //-------------------------------------------------------------------------
  // Internal signals: mapped I and Q for each symbol and interpolated values.
  //-------------------------------------------------------------------------
  // Arrays to hold the mapped I and Q components for each of the N symbols.
  wire signed [OUT_WIDTH-1:0] I_sym [0:N-1];
  wire signed [OUT_WIDTH-1:0] Q_sym [0:N-1];

  // Arrays to hold the interpolated I and Q components for each pair.
  wire signed [OUT_WIDTH-1:0] I_interp [0:N/2-1];
  wire signed [OUT_WIDTH-1:0] Q_interp [0:N/2-1];

  //-------------------------------------------------------------------------
  // Function: map2bit
  // Maps a 2-bit input to the corresponding QAM16 value.
  //-------------------------------------------------------------------------
  function automatic signed [OUT_WIDTH-1:0] map2bit(input logic [1:0] b);
    case(b)
      2'b00: map2bit = -3;
      2'b01: map2bit = -1;
      2'b10: map2bit =  1;
      2'b11: map2bit =  3;
      default: map2bit = 0; // Should not occur.
    endcase
  endfunction

  //-------------------------------------------------------------------------
  // Mapping: Extract each QAM16 symbol from the packed input "bits"
  // and map its MSBs and LSBs to I and Q components.
  //-------------------------------------------------------------------------
  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : mapping_loop
      // For symbol i, extract the MSBs (bits [3:2]) and LSBs (bits [1:0]).
      // Note: Each symbol is 4 bits wide.
      wire [1:0] I_bits = bits[4*i +: 2];  // Bits [3:2] of symbol i
      wire [1:0] Q_bits = bits[4*i +: 2];  // Bits [1:0] of symbol i
      // Map the extracted bits to the corresponding signed value.
      assign I_sym[i] = map2bit(I_bits);
      assign Q_sym[i] = map2bit(Q_bits);
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Interpolation: For every pair of consecutive symbols, compute the
  // interpolated I and Q components as the arithmetic mean.
  // The addition is performed in a wider bit-width (OUT_WIDTH+1) to
  // accommodate the sum before dividing by 2.
  //-------------------------------------------------------------------------
  genvar j;
  generate
    for (j = 0; j < N/2; j = j + 1) begin : interpolation_loop
      // Sign-extend I_sym[j] and I_sym[j+1] to (OUT_WIDTH+1) bits.
      wire signed [OUT_WIDTH:0] ext_I1 = {{1{I_sym[j][OUT_WIDTH-1]}}, I_sym[j]};
      wire signed [OUT_WIDTH:0] ext_I2 = {{1{I_sym[j+1][OUT_WIDTH-1]}}, I_sym[j+1]};
      wire signed [OUT_WIDTH:0] sum_I  = ext_I1 + ext_I2;
      // Compute the interpolated I component (division by 2 gives a 4-bit result).
      wire signed [OUT_WIDTH:0] interp_I_temp = sum_I / 2;
      // Take the lower OUT_WIDTH bits as the final interpolated value.
      assign I_interp[j] = interp_I_temp[OUT_WIDTH-1:0];

      // Repeat the same for Q components.
      wire signed [OUT_WIDTH:0] ext_Q1 = {{1{Q_sym[j][OUT_WIDTH-1]}}, Q_sym[j]};
      wire signed [OUT_WIDTH:0] ext_Q2 = {{1{Q_sym[j+1][OUT_WIDTH-1]}}, Q_sym[j+1]};
      wire signed [OUT_WIDTH:0] sum_Q  = ext_Q1 + ext_Q2;
      wire signed [OUT_WIDTH:0] interp_Q_temp = sum_Q / 2;
      assign Q_interp[j] = interp_Q_temp[OUT_WIDTH-1:0];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Output Packing:
  // Arrange the outputs in the order:
  //   First mapped symbol, then interpolated sample, then second mapped symbol,
  // for each pair.
  // Total segments = 3 per pair, so overall width = (N + N/2)*OUT_WIDTH.
  //-------------------------------------------------------------------------
  genvar k;
  generate
    for (k = 0; k < N/2; k = k + 1) begin : pack_loop
      // Pack I: first mapped symbol, then interpolated, then second mapped symbol.
      assign I[(k*3+0)*OUT_WIDTH +: OUT_WIDTH] = I_sym[k];
      assign I[(k*3+1)*OUT_WIDTH +: OUT_WIDTH] = I_interp[k];
      assign I[(k*3+2)*OUT_WIDTH +: OUT_WIDTH] = I_sym[k+1];

      // Pack Q: first mapped symbol, then interpolated, then second mapped symbol.
      assign Q[(k*3+0)*OUT_WIDTH +: OUT_WIDTH] = Q_sym[k];
      assign Q[(k*3+1)*OUT_WIDTH +: OUT_WIDTH] = Q_interp[k];
      assign Q[(k*3+2)*OUT_WIDTH +: OUT_WIDTH] = Q_sym[k+1];
    end
  endgenerate

endmodule