module swizzler
    #(
        parameter integer NUM_LANES = 4,
        parameter integer DATA_WIDTH = 8,
        parameter integer REGISTER_OUTPUT = 0,
        parameter integer ENABLE_PARITY_CHECK = 0
    )
    (
        input  wire                          clk,
        input  wire                          rst_n,
        input  wire                          bypass,
        input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
        input  wire [NUM_LANES*$clog2(NUM_LANES)-1:0] swizzle_map_flat,
        output reg  [NUM_LANES*DATA_WIDTH-1:0] data_out,
        output reg                           parity_error
    );

    // Unpack data_in into an array of individual lanes
    logic [DATA_WIDTH-1:0] input_lanes[NUM_LANES-1:0];
    foreach (i in 0.NUM_LANES-1) begin
        data_in[(i+1)*DATA_WIDTH-1:DATA_WIDTH] = input_lanes[i];
    end

    // Convert swizzle_map_flat into an array of pointers
    logic [NUM_LANES-1:0] swizzle_map[NUM_LANES-1:0];
    foreach (i in 0.NUM_LANES-1) begin
        swizzle_map[i] = (i+1)*$clog2(NUM_LANES)-1;
    end

    // Perform lane remapping
    if (bypass) begin
        data_out = data_in;
    else begin
        foreach (i in 0.NUM_LANES-1) begin
            data_out[i*DATA_WIDTH-1:DATA_WIDTH] = input_lanes[swizzle_map[i]];
        end
    end

    // Optional parity checking
    if (ENABLE_PARITY_CHECK) begin
        logic parity[NUM_LANES-1:0];
        foreach (i in 0.NUM_LANES-1) begin
            parity[i] = 0;
            foreach (j in 0.DATA_WIDTH-1) begin
                parity[i] ^= (input_lanes[swizzle_map[i]][j] & 1);
            end
        end
        parity_error = parity != 0;
    end
endmodule