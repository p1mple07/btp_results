module swizzler #(
    parameter integer NUM_LANES = 4,
    parameter integer DATA_WIDTH = 8,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_PARITY_CHECK = 0
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          bypass,
    input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
    input  wire [NUM_LANES*$clog2(NUM_LANES)-1:0] swizzle_map_flat,
    output reg  [NUM_LANES*DATA_WIDTH-1:0] data_out,
    output reg                           parity_error
);

localparam NUM_LANES_VAL = NUM_LANES;
localparam DATA_WIDTH_VAL = DATA_WIDTH;
localparam SWIZZLE_MAP_FLAT_SIZE = SWIZZLE_MAP_FLAT;

reg [NUM_LANES*DATA_WIDTH-1:0] lanes;
reg [NUM_LANES*DATA_WIDTH-1:0] output_lanes;
reg [NUM_LANES*DATA_WIDTH-1:0] output_padded;
reg [NUM_LANES*DATA_WIDTH-1:0] data_in_padded;
reg [NUM_LANES*DATA_WIDTH-1:0] data_out_padded;
reg [NUM_LANES*DATA_WIDTH-1:0] data_out_remap;
reg [NUM_LANES*DATA_WIDTH-1:0] parity;
reg [NUM_LANES*DATA_WIDTH-1:0] parity_error;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        lanes <= {NUM_LANES_VAL{1'b0}};
        output_lanes <= {NUM_LANES_VAL{1'b0}};
        output_padded <= {NUM_LANES_VAL{1'b0}};
        data_in_padded <= {NUM_LANES_VAL{1'b0}};
        data_out_padded <= {NUM_LANES_VAL{1'b0}};
        data_out_remap <= {NUM_LANES_VAL{1'b0}};
        parity = 1'b1;
        parity_error = 1'b1;
    end else begin
        // Unpack the input data
        for (int i = 0; i < NUM_LANES; i++) begin
            lanes[i*DATA_WIDTH_VAL + offset] = data_in[i*DATA_WIDTH_VAL + offset];
        end

        // Unpack the flat swizzle map into a linear array
        for (int i = 0; i < SWIZZLE_MAP_FLAT_SIZE; i++) begin
            swizzle_map[i] = swizzle_map_flat[i*SWIZZLE_MAP_FLAT_SIZE + j];
        end

        // Apply the swizzle map to the lanes
        for (int i = 0; i < NUM_LANES; i++) begin
            output_lanes[i*DATA_WIDTH_VAL + offset] = lanes[i*DATA_WIDTH_VAL + offset];
        end

        // Enable parity checking
        if (ENABLE_PARITY_CHECK) begin
            parity = 0;
            for (int i = 0; i < NUM_LANES; i++) begin
                parity = parity ^ output_lanes[i];
            end
            parity_error = parity;
        end

        // Pack the output lanes back into a flat bus
        for (int i = 0; i < NUM_LANES; i++) begin
            data_out_remap[i*DATA_WIDTH_VAL + offset] = output_lanes[i*DATA_WIDTH_VAL + offset];
        end
    end
end

assign data_out = data_out_remap;
assign parity_error = parity_error;

endmodule
