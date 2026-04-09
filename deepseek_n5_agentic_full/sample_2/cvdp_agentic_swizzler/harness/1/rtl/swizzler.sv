module swizzler(#(
    parameter integer NUM_LANES = 4,
    parameter integer DATA_WIDTH = 8,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_PARITY_CHECK = 1))
(
    input wire clk,
    input wire rst_n,
    input wire bypass,
    input wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
    input wire [NUM_LANES:$clog2(NUM_LANES)-1:0] swizzle_map_flat,
    output reg [NUM_LANES*DATA_WIDTH-1:0] data_out,
    output reg parity_error
)
{
    // Unpack input data into lanes
    logic [DATA_WIDTH-1:0] lanes[NUM_LANES-1:0];
    
    // Unpack swizzle map into lanes
    logic [DATA_WIDTH-1:0] swizzle_map[NUM_LANES-1:0];
    
    // Copy input data to lanes
    for (int i = 0; i < NUM_LANES; i++) {
        lanes[i] = data_in[i * DATA_WIDTH];
    }
    
    // Apply swizzle map if bypass is not active
    if (!bypass) {
        for (int i = 0; i < NUM_LANES; i++) {
            int src_lane = swizzle_map[i];
            lanes[i] = data_in[src_lane * DATA_WIDTH];
        }
    }
    
    // Pack lanes back into data_out
    for (int i = 0; i < NUM_LANES; i++) {
        data_out[i * DATA_WIDTH] = lanes[i];
    }
    
    // Perform optional parity check
    if (ENABLE_PARITY_CHECK) {
        logic parity[NUM_LANES-1:0];
        
        for (int i = 0; i < NUM_LANES; i++) {
            parity[i] = 0;
            for (int j = 0; j < DATA_WIDTH; j++) {
                parity[i] ^= lanes[i][j];
            }
            
            if (parity[i]) {
                parity_error = 1;
            }
        }
    }
}