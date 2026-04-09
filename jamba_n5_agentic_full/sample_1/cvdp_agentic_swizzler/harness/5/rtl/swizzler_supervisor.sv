`timescale 1ns/1ps

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

// Instantiate the swizzler module
swizzler #(.NUM_LANES(NUM_LANES), .DATA_WIDTH(DATA_WIDTH), .REGISTER_OUTPUT(REGISTER_OUTPUT), .ENABLE_PARITY_CHECK(ENABLE_PARITY_CHECK), .OP_MODE_WIDTH(OP_MODE_WIDTH), .SWIZZLE_MAP_WIDTH(SWIZZLE_MAP_WIDTH)) uut (
  .clk(clk),
  .rst_n(rst_n),
  .bypass(bypass),
  .data_in(data_in),
  .swizzle_map_flat(swizzle_map_flat),
  .operation_mode(operation_mode),
  .data_out(data_out_swizzler),
  .parity_error(parity_error_internal),
  .invalid_mapping_error(invalid_mapping_internal)
);

// Detect errors
wire top_error_flag;
assign top_error_flag = (invalid_mapping_internal || parity_error_internal);

// Convert data to final output
assign final_data_out = (~data_out_swizzler)[0];

// Generate top‑level error
assign top_error = top_error_flag;

endmodule
