module swizzler #(
    parameter integer NUM_LANES = 4,
    parameter integer DATA_WIDTH = 8,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_PARITY_CHECK = 0
) (
    input  wire                    [NUM_LANES*DATA_WIDTH-1:0] data_in,
    input  wire [NUM_LANES*$clog2(NUM_LANES)-1:0]   swizzle_map_flat,
    output reg  [NUM_LANES*DATA_WIDTH-1:0] data_out,
    output reg                           parity_error
)

// Unpack input lanes
reg logic [NUM_LANES-1:0][DATA_WIDTH-1:0] input_lanes;
always @(*) begin
    for (int i = 0; i < NUM_LANES; i++) {
        input_lanes[i] = data_in[((i+1)*DATA_WIDTH - 1):((i+1)*DATA_WIDTH)];
    }
end

// Unpack swizzle map
reg logic [NUM_LANES-1:0][$clog2(NUM_LANES)-1:0] swizzle_map;
always @(*) begin
    for (int i = 0; i < NUM_LANES; i++) {
        int pos = i;
        for (int j = 0; j < $clog2(NUM_LANES); j++) {
            if (((pos >> j) & 1)) {
                swizzle_map[i] |= (1 << ($clog2(NUM_LANES) - 1 - j));
            }
        }
    }
end

// Generate mapped_lanes based on bypass or swizzle map
reg logic [NUM_LANES-1:0][DATA_WIDTH-1:0] mapped_lanes;
if (bypass) {
    mapped_lanes = input_lanes;
} else {
    for (int i = 0; i < NUM_LANES; i++) {
        mapped_lanes[i] = input_lanes[swizzle_map[i]];
    }
}

// Compute parity for each lane
reg parity_error = 0;
always @(*) begin
    for (int i = 0; i < NUM_LANES; i++) {
        int parity = 0;
        for (int j = 0; j < DATA_WIDTH; j++) {
            parity ^= ((mapped_lanes[i] >> (DATA_WIDTH - 1 - j)) & 1);
        }
        parity_error = parity_error | (parity != 0);
    }
end

// Pack mapped_lanes into data_out
wire [NUM_LANES*DATA_WIDTH-1:0] data_out;
always @(*) begin
    for (int i = 0; i < NUM_LANES; i++) {
        for (int j = 0; j < DATA_WIDTH; j++) {
            data_out[((i << DATA_WIDTH) + j)] = (mapped_lanes[i] >> (DATA_WIDTH - 1 - j)) & 1;
        }
    }
end

// Optional output registering
reg data_reg;
always @positive_edgeclk begin
    data_reg <= data_out;
end
if (REGISTER_OUTPUT) begin
    data_out <= data_reg;
end

endmodule