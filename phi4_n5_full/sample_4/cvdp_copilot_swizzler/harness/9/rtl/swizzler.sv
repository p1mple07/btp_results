module swizzler #(
    // Parameter N: Number of serial data lanes (default is 8)
    parameter int N = 8
)(
    input  logic                        clk,
    input  logic                        reset,
    // Serial Input data lanes
    input  logic [N-1:0]                data_in,
    // Encoded mapping input: concatenation of N mapping indices, each M bits wide.
    // M is now defined as $clog2(N+1) to allow detection of invalid indices (>= N).
    input  logic [N*$clog2(N+1)-1:0]    mapping_in,
    // Control signal: 0 - mirror the swizzled data (reverse bit order), 1 - pass swizzled data directly.
    input  logic                        config_in,
    // Operation mode: selects the transformation applied after swizzling.
    // 3'b000: Swizzle Only / Passthrough (3'b001)
    // 3'b010: Reverse (bit reversal)
    // 3'b011: Swap Halves
    // 3'b100: Bitwise Inversion
    // 3'b101: Circular Left Shift
    // 3'b110: Circular Right Shift
    // 3'b111: Default (same as Swizzle Only)
    input  logic [2:0]                  operation_mode,
    // Serial Output data lanes
    output logic [N-1:0]                data_out,
    // Error flag: asserted if any mapping index is invalid (>= N)
    output logic                        error_flag
);

  //--------------------------------------------------------------------------
  // Local Parameters and Functions
  //--------------------------------------------------------------------------

  // M is defined as $clog2(N+1) to allow detection of indices equal to N.
  localparam int M = $clog2(N+1);

  // Function to reverse the bit order of an N-bit vector.
  function automatic [N-1:0] reverse_bits;
    input  [N-1:0] in;
    integer k;
    [N-1:0] out;
    begin
      out = '0;
      for (k = 0; k < N; k = k + 1) begin
         out[k] = in[N-1-k];
      end
      reverse_bits = out;
    end
  endfunction

  //--------------------------------------------------------------------------
  // Stage 1: Swizzle Calculation and Error Detection
  //--------------------------------------------------------------------------

  // Extract each mapping index from mapping_in.
  // Each mapping index is M bits wide.
  logic [M-1:0] map_idx [N];
  genvar j;
  generate
    for (j = 0; j < N; j++) begin : lane_mapping
      assign map_idx[j] = mapping_in[j*M +: M];
    end
  endgenerate

  // Compute temporary swizzled data.
  // For each lane i:
  //   - If map_idx[i] is valid (i.e. < N), then data_in[map_idx[i]] is used.
  //   - If map_idx[i] is invalid (>= N), then the bit is forced to 0 and an error is flagged.
  reg [N-1:0] swizzle_comb;
  wire        error_detected;
  integer     i;
  always_comb begin
    swizzle_comb = '0;
    error_detected = 1'b0;
    for (i = 0; i < N; i = i + 1) begin
      if (map_idx[i] >= N) begin
        swizzle_comb[i] = 1'b0;
        error_detected = 1'b1;
      end else begin
        swizzle_comb[i] = data_in[map_idx[i]];
      end
    end
  end

  // Apply config_in control: if config_in is 1, pass the swizzled data directly;
  // if config_in is 0, mirror (bit reverse) the swizzled data.
  wire [N-1:0] processed_swizzle_data;
  assign processed_swizzle_data = (config_in) ? swizzle_comb : reverse_bits(swizzle_comb);

  // Pipeline register for the swizzle stage.
  reg [N-1:0] swizzle_reg;
  reg         error_reg;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      swizzle_reg  <= '0;
      error_reg    <= 1'b0;
    end else begin
      swizzle_reg  <= processed_swizzle_data;
      error_reg    <= error_detected;
    end
  end

  //--------------------------------------------------------------------------
  // Stage 2: Operation Transformation
  //--------------------------------------------------------------------------

  // Combinational logic to apply the selected operation_mode transformation on swizzle_reg.
  // The available operations are:
  //   3'b000 / 3'b001: No transformation (Swizzle Only / Passthrough)
  //   3'b010: Reverse the bit order.
  //   3'b011: Swap halves (lower half becomes upper, and vice versa).
  //   3'b100: Bitwise inversion.
  //   3'b101: Circular left shift by 1.
  //   3'b110: Circular right shift by 1.
  //   3'b111: Default (same as Swizzle Only)
  wire [N-1:0] op_reg_comb;
  always_comb begin
    case (operation_mode)
      3'b000, 3'b001: op_reg_comb = swizzle_reg;
      3'b010:         op_reg_comb = reverse_bits(swizzle_reg);
      3'b011: begin
                integer k;
                [N-1:0] tmp;
                begin
                  tmp = '0;
                  // Swap halves: for even N, simply swap; for odd N, the middle bit remains unchanged.
                  if ((N % 2) == 0) begin
                    for (k = 0; k < N/2; k = k + 1) begin
                      tmp[k]       = swizzle_reg[N-1-k];
                      tmp[N-1-k]   = swizzle_reg[k];
                    end
                  end else begin
                    for (k = 0; k < N/2; k = k + 1) begin
                      tmp[k]       = swizzle_reg[N-1-k];
                      tmp[N-1-k]   = swizzle_reg[k];
                    end
                    tmp[N/2] = swizzle_reg[N/2];
                  end
                  op_reg_comb = tmp;
                end
              end
      3'b100:         op_reg_comb = ~swizzle_reg;
      3'b101:         op_reg_comb = { swizzle_reg[N-1], swizzle_reg[N-1:1] }; // Circular left shift
      3'b110:         op_reg_comb = { swizzle_reg[0], swizzle_reg[1:N-1] }; // Circular right shift
      3'b111:         op_reg_comb = swizzle_reg;
      default:        op_reg_comb = swizzle_reg;
    endcase
  end

  // Pipeline register for the operation stage.
  reg [N-1:0] operation_reg;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      operation_reg <= '0;
    end else begin
      operation_reg <= op_reg_comb;
    end
  end

  //--------------------------------------------------------------------------
  // Stage 3: Final Bit Reversal and Output
  //--------------------------------------------------------------------------

  // The final stage reindexes the bits so that the most significant bit in Verilog
  // corresponds to the leftmost bit in external representations.
  // This is achieved by reversing the bits of operation_reg.
  wire [N-1:0] final_stage;
  assign final_stage = reverse_bits(operation_reg);

  // Pipeline register for the final output.
  reg [N-1:0] final_reg;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      final_reg   <= '0;
      data_out    <= '0;
    end else begin
      final_reg   <= final_stage;
      data_out    <= final_reg;
    end
  end

  // Drive the error_flag output from the registered error status.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      error_flag <= 1'b0;
    end else begin
      error_flag <= error_reg;
    end
  end

endmodule