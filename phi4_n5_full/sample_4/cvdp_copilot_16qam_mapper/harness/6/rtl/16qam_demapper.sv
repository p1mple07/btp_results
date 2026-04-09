module qam16_demapper_interpolated #(
  parameter int N              = 4,    // Number of mapped symbols (≥2 and even)
  parameter int OUT_WIDTH      = 4,    // Bit width of each output symbol (fixed at 4)
  parameter int IN_WIDTH       = 3,    // Bit width of I/Q components (fixed at 3)
  parameter int ERROR_THRESHOLD = 1     // Predefined threshold for error detection
)(
  input  logic [ (3*(N/2))*IN_WIDTH - 1 : 0 ] I,  // Packed I vector: [mapped, interpolated, mapped] repeated
  input  logic [ (3*(N/2))*IN_WIDTH - 1 : 0 ] Q,  // Packed Q vector: same structure as I
  output logic [ N*OUT_WIDTH - 1 : 0 ] bits,       // Packed output bit stream (each symbol is 4 bits)
  output logic error_flag                           // Global error flag (1 if any interpolated deviation exceeds threshold)
);

  // Total number of segments in the input vectors.
  // Each group consists of 3 segments: first mapped, interpolated, second mapped.
  localparam int TOTAL_SEGMENTS = 3*(N/2);  // Note: TOTAL_SEGMENTS == N + (N/2)

  // Combinational logic: extract segments, perform error detection, and build output bits.
  always_comb begin
    // Default error flag
    error_flag = 1'b0;
    
    // Temporary arrays to hold individual segments.
    // Each segment is a signed value with width IN_WIDTH.
    logic signed [IN_WIDTH-1:0] i_seg [0:TOTAL_SEGMENTS-1];
    logic signed [IN_WIDTH-1:0] q_seg [0:TOTAL_SEGMENTS-1];
    
    // Extract each segment from the packed input vectors.
    for (int seg = 0; seg < TOTAL_SEGMENTS; seg = seg + 1) begin
      i_seg[seg] = I[seg*IN_WIDTH +: IN_WIDTH];
      q_seg[seg] = Q[seg*IN_WIDTH +: IN_WIDTH];
    end
    
    // Error detection: For each group, compare the interpolated sample with the average of the two mapped samples.
    // Each group (group index = 0 to (N/2)-1) has:
    //   mapped sample 1 at index = 3*group
    //   interpolated sample at index = 3*group + 1
    //   mapped sample 2 at index = 3*group + 2
    for (int group = 0; group < (N/2); group = group + 1) begin
      int mapped_i0 = 3 * group;
      int interp_i  = 3 * group + 1;
      int mapped_i1 = 3 * group + 2;
      
      // Expected interpolated value for I: average of the two mapped samples.
      int expected_i = (i_seg[mapped_i0] + i_seg[mapped_i1]) / 2;
      int diff_i     = i_seg[interp_i] - expected_i;
      int abs_diff_i = (diff_i < 0) ? -diff_i : diff_i;
      if (abs_diff_i >= ERROR_THRESHOLD)
        error_flag = 1'b1;
      
      // Similarly for Q.
      int expected_q = (q_seg[mapped_i0] + q_seg[mapped_i1]) / 2;
      int diff_q     = q_seg[interp_i] - expected_q;
      int abs_diff_q = (diff_q < 0) ? -diff_q : diff_q;
      if (abs_diff_q >= ERROR_THRESHOLD)
        error_flag = 1'b1;
    end
    
    // Build the output bits vector.
    // Each mapped symbol is converted to a 4-bit value where:
    //   - The most significant 2 bits come from the I component.
    //   - The least significant 2 bits come from the Q component.
    // Mapping: -3 -> 00, -1 -> 01, 1  -> 10, 3  -> 11.
    // The mapped samples occur in order: for group i, the first mapped sample (index = 3*i)
    // and the second mapped sample (index = 3*i + 2). The output ordering is:
    //   symbol 0: group0, first mapped sample;
    //   symbol 1: group0, second mapped sample;
    //   symbol 2: group1, first mapped sample;
    //   symbol 3: group1, second mapped sample; etc.
    logic [N*OUT_WIDTH-1:0] bits_local;
    for (int j = 0; j < N; j = j + 1) begin
      int group, seg_idx;
      if (j % 2 == 0) begin
        group    = j / 2;
        seg_idx  = 3 * group;           // First mapped sample of group
      end else begin
        group    = (j - 1) / 2;
        seg_idx  = 3 * group + 2;        // Second mapped sample of group
      end
      
      // Map the I component to 2 bits.
      logic [1:0] i_mapped;
      case (i_seg[seg_idx])
        -3: i_mapped = 2'b00;
        -1: i_mapped = 2'b01;
         1: i_mapped = 2'b10;
         3: i_mapped = 2'b11;
        default: i_mapped = 2'bxx;  // Undefined mapping for unexpected values.
      endcase
      
      // Map the Q component to 2 bits.
      logic [1:0] q_mapped;
      case (q_seg[seg_idx])
        -3: q_mapped = 2'b00;
        -1: q_mapped = 2'b01;
         1: q_mapped = 2'b10;
         3: q_mapped = 2'b11;
        default: q_mapped = 2'bxx;
      endcase
      
      // Combine the mapped I and Q bits to form a 4-bit symbol.
      // The most significant 2 bits come from I, and the least significant 2 bits come from Q.
      bits_local[j*OUT_WIDTH +: OUT_WIDTH] = { i_mapped, q_mapped };
    end
    
    bits = bits_local;
  end

endmodule