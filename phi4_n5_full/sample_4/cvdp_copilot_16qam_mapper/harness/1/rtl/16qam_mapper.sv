module qam16_mapper_interpolated #(
  parameter N       = 4,  // Number of input symbols (must be ≥ 2 and a multiple of 2)
  parameter IN_WIDTH = 4,  // Bit width of each input symbol (fixed at 4)
  parameter OUT_WIDTH = 3  // Bit width of output components (fixed at 3)
)(
  input  logic [N*IN_WIDTH-1:0] bits,  // Packed input bits: each group of 4 bits represents one QAM16 symbol
  output logic [(N + N/2)*OUT_WIDTH - 1:0] I,  // Packed output: mapped and interpolated I components
  output logic [(N + N/2)*OUT_WIDTH - 1:0] Q   // Packed output: mapped and interpolated Q components
);

  // Local arrays to hold mapped I and Q values for each input symbol
  logic signed [OUT_WIDTH-1:0] mapped_I [0:N-1];
  logic signed [OUT_WIDTH-1:0] mapped_Q [0:N-1];

  // Local arrays to hold interpolated values (using one extra bit for addition)
  logic signed [OUT_WIDTH:0] interp_I [0:(N/2)-1];
  logic signed [OUT_WIDTH:0] interp_Q [0:(N/2)-1];

  // Combinational logic: Map input bits and compute interpolations
  always_comb begin
    // Process each input symbol
    for (int i = 0; i < N; i++) begin
      // Extract one 4-bit symbol from the packed input vector
      bit [IN_WIDTH-1:0] sym = bits[i*IN_WIDTH +: IN_WIDTH];
      
      // Map the MSBs (bits [3:2]) to the I component
      case (sym[3:2])
        2'b00: mapped_I[i] = -3;
        2'b01: mapped_I[i] = -1;
        2'b10: mapped_I[i] =  1;
        2'b11: mapped_I[i] =  3;
        default: mapped_I[i] = 0;  // Default case (should not occur)
      endcase

      // Map the LSBs (bits [1:0]) to the Q component
      case (sym[1:0])
        2'b00: mapped_Q[i] = -3;
        2'b01: mapped_Q[i] = -1;
        2'b10: mapped_Q[i] =  1;
        2'b11: mapped_Q[i] =  3;
        default: mapped_Q[i] = 0;  // Default case (should not occur)
      endcase
    end

    // Compute interpolated values for each pair of consecutive symbols
    for (int j = 0; j < N/2; j++) begin
      // Interpolated I: arithmetic mean of mapped_I[2*j] and mapped_I[2*j+1]
      interp_I[j] = (mapped_I[2*j] + mapped_I[2*j+1]) >>> 1;
      
      // Interpolated Q: arithmetic mean of mapped_Q[2*j] and mapped_Q[2*j+1]
      interp_Q[j] = (mapped_Q[2*j] + mapped_Q[2*j+1]) >>> 1;
    end
  end

  // Pack the outputs in the order: mapped symbol, interpolated value, next mapped symbol.
  // This is done separately for I and Q.
  genvar k;
  generate
    // Pack I output: for each pair, assign mapped_I[2*k], interp_I[k], mapped_I[2*k+1]
    for (k = 0; k < N/2; k = k + 1) begin : pack_I
      I[(3*k)*OUT_WIDTH +: OUT_WIDTH]      = mapped_I[2*k];
      I[(3*k + 1)*OUT_WIDTH +: OUT_WIDTH]   = interp_I[k][OUT_WIDTH-1:0];
      I[(3*k + 2)*OUT_WIDTH +: OUT_WIDTH]   = mapped_I[2*k+1];
    end
  endgenerate

  generate
    // Pack Q output: for each pair, assign mapped_Q[2*k], interp_Q[k], mapped_Q[2*k+1]
    for (k = 0; k < N/2; k = k + 1) begin : pack_Q
      Q[(3*k)*OUT_WIDTH +: OUT_WIDTH]      = mapped_Q[2*k];
      Q[(3*k + 1)*OUT_WIDTH +: OUT_WIDTH]   = interp_Q[k][OUT_WIDTH-1:0];
      Q[(3*k + 2)*OUT_WIDTH +: OUT_WIDTH]   = mapped_Q[2*k+1];
    end
  endgenerate

endmodule