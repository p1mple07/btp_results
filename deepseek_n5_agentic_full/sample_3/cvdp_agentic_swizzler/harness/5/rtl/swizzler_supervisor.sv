module swizzler_supervisor #(
  parameter integer NUM_LANES           = 4,
  parameter integer DATA_WIDTH          = 8,
  parameter integer REGISTER_OUTPUT     = 1,
  parameter integer ENABLE_PARITY_CHECK = 1,
  parameter integer OP_MODE_WIDTH       = 2,
  parameter integer SWIZZLE_MAP_WIDTH   = $clog2(NUM_LANES)+1,
  parameter [DATA_WIDTH-1:0] EXPECTED_CHECKSUM = 8'hA5
)(
  input  wire                          _clk,
  input  wire                          _rST_n,
  input  wire                          _bypass,
  input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
  input  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat,
  input  wire [OP_MODE_WIDTH-1:0]         operation_mode,
  output reg [NUM_LANES*DATA_WIDTH-1:0] final_data_out,
  output reg                              top_error
);
  // Internal Implementation
  reg [DATA_WIDTH-1:0] lane_in[NUM_LANES];
  genvar ii;
  always @* begin
    if (!rST_n) begin
      for[ii = 0; ii < NUM_LANES; ii = ii + 1] begin
        lane_in[ii] = data_in[(ii)*DATA_WIDTH:(ii+1)*DATA_WIDTH-1];
      end
    end
  end

  wire [NUM_LANES*DATA_WIDTH-1:0] data_out;
  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat_processed;
  wire [NUM_LANES*DATA_WIDTH-1:0] processed_swizzled;
  wire [NUM_LANES*DATA_WIDTH-1:0] final_packed;
  
  // Process swizzler
  wire [NUM_LANES*DATA_WIDTH-1:0] swizzled;
  genvar gi;
  generate
    for(gi = 0; gi < NUM_LANES; gi = gi + 1) begin : UNPACK_INPUT
      assign swizzled[gi] = bypass ? lane_in[gi] : lane_in[ 
        swizzle_map[gi][$(DATA_WIDTH-1):0] ];
    end
  endgenerate

  // Parity Check
  reg [NUM_LANES-1:0] even_lane;
  reg parity_even;
  reg parity_odd;
  reg total_parity;
  generate
    if(ENABLE_PARITY_CHECK) begin
      for(gi = 0; gi < NUM_LANES; gi = gi + 1) begin
        even_lane[gi] = (swizzled[gi] & 1) ? 1 : 0;
      end
      parity_even = even_lane[0];
      for(gi = 1; gi < NUM_LANES; gi = gi + 1) begin
        parity_even = parity_even ^ even_lane[gi];
      end
      parity_odd = 0;
      total_parity = parity_even ^ parity_odd;
    end
  endgenerate
  
  // Checksum Calculation
  reg checksum = 0;
  generate
    if(REGISTER_OUTPUT) begin
      for(gi = 0; gi < NUM_LANES; gi = gi + 1) begin
        checksum ^= swizzled[gi];
      end
    endif
  endgenerate

  // Compare_checksum
  reg matched_checksum = 1'b0;
  always @*begin
    if(ENABLE_PARITY_CHECK && !rST_n) begin
      if(checksum == (8'hA5)) {
        matched_checksum = 1'b1;
      } else {
        matched_checksum = 1'b0;
      }
    endif
  endalways

  // Error Flags
  wire invalid_mapping_error_swiz;
  wire parity_error_swiz;
  wire error_flags[NUM_LANES];

  reg op_valid_reg;
  reg op_invalid_reg;

  // Combine Outputs
  final_data_out = packed_final;
  always @*begin
    if(!rST_n) begin
      for(ii = 0; ii < NUM_LANES; ii = ii + 1) begin
        final_data_out[ii*DATA_WIDTH:ii*DATA_WIDTH+DATA_WIDTH-1] = final_packed[ii];
      end
    endif
  endalways

  // Error Reporting
  always @posedge clocks begin
    if(top_error) begin
      $display("Error: Checksum mismatch or invalid mapping");
      // Add additional error reporting logic here
    end
  endposedge;
endmodule