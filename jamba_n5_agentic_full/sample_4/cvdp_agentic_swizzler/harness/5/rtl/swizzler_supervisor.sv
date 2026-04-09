module swizzler_supervisor (#(
  parameter integer NUM_LANES           = 4,
  parameter integer DATA_WIDTH          = 8,
  parameter integer REGISTER_OUTPUT     = 1,
  parameter integer ENABLE_PARITY_CHECK = 1,
  parameter integer OP_MODE_WIDTH       = 2,
  parameter integer SWIZZLE_MAP_WIDTH   = $clog2(NUM_LANES)+1,
  parameter [DATA_WIDTH-1:0] EXPECTED_CHECKSUM = 8'hA5
) (
  input  wire clk,
  input  wire rst_n,
  input  wire bypass,
  input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
  input  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat,
  input  wire [OP_MODE_WIDTH-1:0]         operation_mode,
  output reg  [NUM_LANES*DATA_WIDTH-1:0] final_data_out,
  output reg                            top_error
);

// Instantiate the swizzler module
swizzler #(.NUM_LANES(NUM_LANES), .DATA_WIDTH(DATA_WIDTH), .REGISTER_OUTPUT(REGISTER_OUTPUT), .ENABLE_PARITY_CHECK(ENABLE_PARITY_CHECK), .OP_MODE_WIDTH(OP_MODE_WIDTH), .SWIZZLE_MAP_WIDTH(SWIZZLE_MAP_WIDTH)) (
  .clk(clk),
  .rst_n(rst_n),
  .bypass(bypass),
  .data_in(data_in),
  .swizzle_map_flat(swizzle_map_flat),
  .operation_mode(operation_mode),
  .data_out(data_out),
  .parity_error(parity_error),
  .invalid_mapping_error(invalid_mapping_error)
);

// Assign final_data_out to the swizzler output
assign final_data_out = data_out;

// Compute parity check
wire [NUM_LANES-1:0] computed_checksum;
always @(*) begin
  computed_checksum = 0;
  for (int i = 0; i < NUM_LANES * DATA_WIDTH; i++)
    computed_checksum += final_data_out[i];
end

// Top-level error generation
wire top_error;
always @(*) begin
  top_error = (~computed_checksum == EXPECTED_CHECKSUM);
end

endmodule
