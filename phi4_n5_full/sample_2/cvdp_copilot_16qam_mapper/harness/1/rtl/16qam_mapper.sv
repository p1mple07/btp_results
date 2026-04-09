module implements a combinational QAM16 mapper with interpolation.
// Each input symbol (4 bits) is split into two 2‐bit parts:
//   • MSBs (bits [3:2]) map to the I (real) component with:
//         00 -> -3, 01 -> -1, 10 ->  1, 11 ->  3
//   • LSBs (bits [1:0]) map to the Q (imaginary) component with the same mapping.
// For every two consecutive symbols, the interpolated value is computed as
//   (mapped_value1 + mapped_value2) / 2.
// The output is arranged in the order:
//   mapped symbol 1, interpolated value, mapped symbol 2, … 
// for both I and Q channels.
//
// Parameters:
//   N         - Number of input symbols (≥ 2 and even, e.g., 2,4,6,…)
//   IN_WIDTH  - Bit width of each input symbol (fixed at 4)
//   OUT_WIDTH - Bit width of each output sample (fixed at 3)
//
module qam16_mapper_interpolated #(
  parameter N         = 4,
  parameter IN_WIDTH  = 4,
  parameter OUT_WIDTH = 3
)(
  input  logic [N*IN_WIDTH-1:0] bits,  // Packed input: N symbols, each 4 bits
  output logic [(N + N/2)*OUT_WIDTH-1:0] I,  // Packed output: mapped and interpolated I values
  output logic [(N + N/2)*OUT_WIDTH-1:0] Q   // Packed output: mapped and interpolated Q values
);

  // Total number of output samples = N (mapped) + (N/2) (interpolated)
  localparam total_samples = N + (N/2);

  //-------------------------------------------------------------------------
  // Internal arrays for mapped values and interpolation results.
  //-------------------------------------------------------------------------
  // Mapped I and Q for each input symbol (each is OUT_WIDTH bits wide)
  logic signed [OUT_WIDTH-1:0] mapped_I [0:N-1];
  logic signed [OUT_WIDTH-1:0] mapped_Q [0:N-1];

  // Interpolated values (need one extra bit to hold the sum before division)
  logic signed [OUT_WIDTH:0] interp_I [0:(N/2)-1];
  logic signed [OUT_WIDTH:0] interp_Q [0:(N/2)-1];

  // Temporary arrays to hold the ordered output samples.
  // For each pair of symbols, we have:
  //   [mapped_I, interp_I, mapped_I_next]
  logic signed [OUT_WIDTH-1:0] out_I [0:total_samples-1];
  logic signed [OUT_WIDTH-1:0] out_Q [0:total_samples-1];

  // Final output arrays (will be used to drive the packed outputs via slice assignments)
  logic signed [OUT_WIDTH-1:0] i_out [0:total_samples-1];
  logic signed [OUT_WIDTH-1:0] q_out [0:total_samples-1];

  //-------------------------------------------------------------------------
  // Main combinational logic: mapping, interpolation, and packing.
  //-------------------------------------------------------------------------
  always_comb begin
    integer i;
    // 1. Mapping: For each symbol extract the 2-bit parts and map them.
    for (i = 0; i < N; i = i + 1) begin
      // Extract the i-th symbol (4 bits)
      bit [IN_WIDTH-1:0] symbol;
      symbol = bits[i*IN_WIDTH +: IN_WIDTH];

      // Extract the MSBs for I and LSBs for Q.
      // (For a 4-bit symbol, bits [3:2] and [1:0] respectively)
      logic [1:0] i_val, q_val;
      i_val = symbol[3:2];
      q_val = symbol[1:0];

      // Map the 2-bit value to the corresponding QAM16 amplitude.
      case (i_val)
        2'b00: mapped_I[i] = -3;
        2'b01: mapped_I[i] = -1;
        2'b10: mapped_I[i] =  1;
        2'b11: mapped_I[i] =  3;
        default: mapped_I[i] = 0;  // Should not occur.
      endcase

      case (q_val)
        2'b00: mapped_Q[i] = -3;
        2'b01: mapped_Q[i] = -1;
        2'b10: mapped_Q[i] =  1;
        2'b11: mapped_Q[i] =  3;
        default: mapped_Q[i] = 0;  // Should not occur.
      endcase
    end

    // 2. Interpolation: Compute the arithmetic mean of consecutive symbols.
    for (i = 0; i < N/2; i = i + 1) begin
      interp_I[i] = (mapped_I[2*i] + mapped_I[2*i+1]) >> 1;
      interp_Q[i] = (mapped_Q[2*i] + mapped_Q[2*i+1]) >> 1;
    end

    // 3. Pack the outputs in the order:
    //    [mapped_I[0], interp_I[0], mapped_I[1],
    //     mapped_I[2], interp_I[1], mapped_I[3], ... ]
    for (i = 0; i < N/2; i = i + 1) begin
      out_I[3*i]     = mapped_I[2*i];
      out_I[3*i+1]   = interp_I[i];
      out_I[3*i+2]   = mapped_I[2*i+1];

      out_Q[3*i]     = mapped_Q[2*i];
      out_Q[3*i+1]   = interp_Q[i];
      out_Q[3*i+2]   = mapped_Q[2*i+1];
    end

    // Copy the packed arrays to the final output arrays.
    for (i = 0; i < total_samples; i = i + 1) begin
      i_out[i] = out_I[i];
      q_out[i] = out_Q[i];
    end
  end

  //-------------------------------------------------------------------------
  // Drive the packed output vectors by assigning slices of the final arrays.
  //-------------------------------------------------------------------------
  genvar idx;
  generate
    for (idx = 0; idx < total_samples; idx = idx + 1) begin : pack_i_loop
      // Each slice of I is OUT_WIDTH bits wide.
      assign I[idx*OUT_WIDTH +: OUT_WIDTH] = i_out[idx];
    end
  endgenerate

  generate
    for (idx = 0; idx < total_samples; idx = idx + 1) begin : pack_q_loop
      assign Q[idx*OUT_WIDTH +: OUT_WIDTH] = q_out[idx];
    end
  endgenerate

endmodule