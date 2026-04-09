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

    // Instantiate the core swizzler component
    swizzler #(
        .NUM_LANES(NUM_LANES),
        .DATA_WIDTH(DATA_WIDTH),
        .REGISTER_OUTPUT(REGISTER_OUTPUT),
        .ENABLE_PARITY_CHECK(ENABLE_PARITY_CHECK),
        .OP_MODE_WIDTH(OP_MODE_WIDTH),
        .SWIZZLE_MAP_WIDTH(SWIZZLE_MAP_WIDTH)
    ) u_swizzler (
        .clk(clk),
        .rst_n(rst_n),
        .bypass(bypass),
        .data_in(data_in),
        .swizzle_map_flat(swizzle_map_flat),
        .operation_mode(operation_mode),
        .data_out(final_data_out),
        .parity_error(top_error)
    );

    // Optional pre‑processing stage – adjust this to match your needs
    reg [DATA_WIDTH-1:0] preprocessed_data;
    always @(posedge clk) begin
        preprocessed_data = data_in;  // simple copy – modify as needed
    end

    // Compute the checksum on the pre‑processed data
    reg [31:0] checksum;
    compute_checksum checksum @(posedge clk);

    // Validate the checksum against the expected value
    always @(*) begin
        top_error = !(checksum == EXPECTED_CHECKSUM);
    end

endmodule
