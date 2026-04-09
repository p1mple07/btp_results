module qam16_mapper_interpolated #(
  parameter N         = 4,       // Number of input symbols (≥2 and multiple of 2)
  parameter IN_WIDTH  = 4,       // Bit width of each input symbol (fixed at 4)
  parameter OUT_WIDTH = 3        // Bit width of each output sample (fixed at 3)
)(
  input  logic [N*IN_WIDTH-1:0] bits,  // Packed input bits: each group of 4 bits represents one QAM16 symbol
  output logic [(N + N/2)*OUT_WIDTH-1:0] I,  // Packed output: real (I) components
  output logic [(N + N/2)*OUT_WIDTH-1:0] Q   // Packed output: imaginary (Q) components
);

  //-------------------------------------------------------------------------
  // Internal arrays to hold the mapped I and Q components for each input symbol
  //-------------------------------------------------------------------------
  logic signed [OUT_WIDTH-1:0] mappedI [0:N-1];
  logic signed [OUT_WIDTH-1:0] mappedQ [0:N-1];

  //-------------------------------------------------------------------------
  // Intermediate arrays for the output samples.
  // For every pair of symbols, we generate three samples:
  //   1. First mapped symbol
  //   2. Interpolated sample (arithmetic mean)
  //   3. Second mapped symbol
  //
  // Total output samples = N/2 * 3 = (N + N/2)
  //-------------------------------------------------------------------------
  localparam int NUM_OUT = (N + N/2);  // Equals 3*(N/2)
  logic signed [OUT_WIDTH-1:0] outI [0:NUM_OUT-1];
  logic signed [OUT_WIDTH-1:0] outQ [0:NUM_OUT-1];

  //-------------------------------------------------------------------------
  // Mapping: For each input symbol, extract the two 2-bit groups and map them.
  // MSBs (bits [IN_WIDTH-1 : IN_WIDTH-2]) map to I:
  //   00 -> -3, 01 -> -1, 10 ->  1, 11 ->  3
  // LSBs (bits [1 : 0]) map to Q using the same table.
  //-------------------------------------------------------------------------
  always_comb begin
    for (int i = 0; i < N; i++) begin
      // Extract one 4-bit symbol from the packed input
      logic [IN_WIDTH-1:0] sym;
      sym = bits[i*IN_WIDTH +: IN_WIDTH];
      
      // Extract the MSBs for I (for IN_WIDTH=4, this is bits [3:2])
      logic [1:0] i_bits = sym[IN_WIDTH-1 -: 2];
      // Extract the LSBs for Q (bits [1:0])
      logic [1:0] q_bits = sym[1:0];
      
      // Map the 2-bit value to the corresponding QAM16 amplitude for I
      case(i_bits)
        2'b00: mappedI[i] = -3;
        2'b01: mappedI[i] = -1;
        2'b10: mappedI[i] =  1;
        2'b11: mappedI[i] =  3;
        default: mappedI[i] = 0;  // Should not occur
      endcase
      
      // Map the 2-bit value to the corresponding QAM16 amplitude for Q
      case(q_bits)
        2'b00: mappedQ[i] = -3;
        2'b01: mappedQ[i] = -1;
        2'b10: mappedQ[i] =  1;
        2'b11: mappedQ[i] =  3;
        default: mappedQ[i] = 0;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Interpolation: For every two consecutive symbols, compute the interpolated
  // sample as the arithmetic mean. Since the sum of two OUT_WIDTH-bit numbers
  // may require one extra bit, an intermediate wider signal is used.
  //
  // The output arrangement for each pair is:
  //   [Mapped symbol 1, Interpolated sample, Mapped symbol 2]
  //-------------------------------------------------------------------------
  always_comb begin
    for (int i = 0; i < N/2; i++) begin
      int idx0 = 3*i;
      int idx1 = 3*i + 1;
      int idx2 = 3*i + 2;
      
      // Compute interpolated I component
      logic signed [OUT_WIDTH:0] sumI = mappedI[2*i] + mappedI[2*i+1];
      logic signed [OUT_WIDTH-1:0] interpI = sumI >> 1;  // Arithmetic right shift divides by 2
      
      // Pack the samples in order: first mapped symbol, then interpolated, then second mapped symbol
      outI[idx0] = mappedI[2*i];
      outI[idx1] = interpI;
      outI[idx2] = mappedI[2*i+1];
      
      // Compute interpolated Q component
      logic signed [OUT_WIDTH:0] sumQ = mappedQ[2*i] + mappedQ[2*i+1];
      logic signed [OUT_WIDTH-1:0] interpQ = sumQ >> 1;
      
      outQ[idx0] = mappedQ[2*i];
      outQ[idx1] = interpQ;
      outQ[idx2] = mappedQ[2*i+1];
    end
  end

  //-------------------------------------------------------------------------
  // Pack the per-sample arrays (outI and outQ) into the output vectors I and Q.
  // Each sample is OUT_WIDTH bits wide.
  //-------------------------------------------------------------------------
  logic [(N + N/2)*OUT_WIDTH-1:0] I_packed;
  logic [(N + N/2)*OUT_WIDTH-1:0] Q_packed;
  integer j;
  always_comb begin
    I_packed = '0;
    Q_packed = '0;
    for (j = 0; j < NUM_OUT; j = j + 1) begin
      I_packed[j*OUT_WIDTH +: OUT_WIDTH] = outI[j];
      Q_packed[j*OUT_WIDTH +: OUT_WIDTH] = outQ[j];
    end
  end

  assign I = I_packed;
  assign Q = Q_packed;

endmodule