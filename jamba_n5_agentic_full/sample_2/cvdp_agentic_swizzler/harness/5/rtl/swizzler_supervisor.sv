module swizzler_supervisor #(
  parameter integer NUM_LANES           = 4,
  parameter integer DATA_WIDTH          = 8,
  parameter integer REGISTER_OUTPUT     = 1,
  parameter integer ENABLE_PARITY_CHECK = 1,
  parameter integer OP_MODE_WIDTH       = 2,
  parameter integer SWIZZLE_MAP_WIDTH   = $clog2(NUM_LANES)+1,
  parameter [DATA_WIDTH-1:0] EXPECTED_CHECKSUM = 8'hA5
)(
  input  wire                           clk,
  input  wire                           rst_n,
  input  wire                           bypass,
  input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
  input  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat,
  input  wire [OP_MODE_WIDTH-1:0]         operation_mode,
  output reg  [NUM_LANES*DATA_WIDTH-1:0]  final_data_out,
  output reg                            top_error
);

// Pre-processing: no changes

// Swizzler instance
swizzler #(.NUM_LANES(NUM_LANES), .DATA_WIDTH(DATA_WIDTH), .REGISTER_OUTPUT(REGISTER_OUTPUT), .ENABLE_PARITY_CHECK(ENABLE_PARITY_CHECK), .OP_MODE_WIDTH(OP_MODE_WIDTH), .SWIZZLE_MAP_WIDTH(SWIZZLE_MAP_WIDTH)) uut (
  .clk(clk),
  .rst_n(rst_n),
  .bypass(bypass),
  .data_in(data_in),
  .swizzle_map_flat(swizzle_map_flat),
  .operation_mode(operation_mode),
  .data_out(uut_data)
);

// Compute checksum from uut_data
wire computed_checksum = uut_data[NUM_LANES*DATA_WIDTH-1:0];

// Compare with expected_checksum
assign top_error = computed_checksum != EXPECTED_CHECKSUM;

// Post-processing: invert LSB of each lane
always @(*) begin
  for (int i = 0; i < NUM_LANES; i++) begin
    uut_data[i] = bit_invert(uut_data[i]);
  end
end

// Output final data
assign final_data_out = uut_data;

endmodule
