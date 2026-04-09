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
swizzler #(
    .NUM_LANES(NUM_LANES),
    .DATA_WIDTH(DATA_WIDTH),
    .REGISTER_OUTPUT(REGISTER_OUTPUT),
    .ENABLE_PARITY_CHECK(ENABLE_PARITY_CHECK),
    .OP_MODE_WIDTH(OP_MODE_WIDTH),
    .SWIZZLE_MAP_WIDTH(SWIZZLE_MAP_WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .bypass(bypass),
    .data_in(data_in),
    .swizzle_map_flat(swizzle_map_flat),
    .operation_mode(operation_mode),
    .data_out(final_data_out),
    .parity_error(top_error),
    .invalid_mapping_error(invalid_mapping_error)
);

// Top-level post-processing logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        top_error = 1'b1;
        return;
    end

    // Perform checksum calculation
    wire computed_checksum = 0;
    for (integer i = 0; i < NUM_LANES; i = i + 1) begin
        computed_checksum ^= final_data_out[i];
    end

    // Compare checksum with expected value
    if (computed_checksum != EXPECTED_CHECKSUM) begin
        top_error = 1'b1;
    end else begin
        top_error = 1'b0;
    end
end

endmodule
