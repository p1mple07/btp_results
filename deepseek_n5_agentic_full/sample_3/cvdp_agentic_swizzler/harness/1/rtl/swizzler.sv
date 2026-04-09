module swizzler(
    parameter integer NUM_LANES = 4,
    parameter integer DATA_WIDTH = 8,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_PARITY_CHECK = 0
) (
    input wire clock,
    input wire rst_n,
    input wire bypass,
    input wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
    input wire [NUM_LANES:$clog2(NUM_LANES)-1:0] swizzle_map_flat,
    output reg [NUM_LANES*DATA_WIDTH-1:0] data_out,
    output reg parity_error
)

// Step 1: Convert flattened input bus to array of individual lanes
    logic [DATA_WIDTH-1:0] lanes[NUM_LANES-1];
    foreach (i in 0 to NUM_LANES-1)
        lanes[i] = data_in[(i+1)*DATA_WIDTH-1 : Data_Width]

// Step 2: Convert flat swizzle map to array format
    logic [NUM_LANES-1:0] swizzle_map[$clog2(NUM_LANES)-1];
    foreach (i in 0 to NUM_LANES-1)
        swizzle_map[i] = swizzle_map_flat[(i+1)*$clog2(NUM_LANES)-1 : clog2(NUM_LANES)]

// Step 3: Perform lane remapping
    logic [DATA_WIDTH-1:0] mapped_lanes[NUM_LANES-1];
    if (!bypass)
        foreach (i in 0 to NUM_LANES-1)
            mapped_lanes[i] = lanes[swizzle_map[i]]
    else
        foreach (i in 0 to NUM_LANES-1)
            mapped_lanes[i] = lanes[i]

// Step 4: Perform parity checking
    logic [DATA_WIDTH-1:0] parity_check[NUM_LANES-1];
    if (ENABLE_PARITY_CHECK)
        foreach (i in 0 to NUM_LANES-1)
            parity_check[i] = mapped_lanes[i] & ((1 << DATA_WIDTH) - 1)
    else
        foreach (i in 0 to NUM_LANES-1)
            parity_check[i] = 0

    // Check for parity errors
    foreach (i in 0 to NUM_LANES-1)
        if (parity_check[i])
            parity_error = 1

// Step 5: Pack remapped lanes back into output bus
    foreach (i in 0 to NUM_LANES-1)
        data_out[(i+1)*DATA_WIDTH-1 : Data_Width] = mapped_lanes[i]

// Step 6: Register output if required
    if (REGISTER_OUTPUT)
        data_out = data_out + 1

endmodule