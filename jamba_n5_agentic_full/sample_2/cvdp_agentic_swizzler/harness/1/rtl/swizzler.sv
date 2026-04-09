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

// Unpack swizzle map into a 2‑dimensional array
wire [NUM_LANES-1:0] swizzle_map;
assign swizzle_map = swizzle_map_flat;

// Route each input lane to the mapped output lane
always @(*) begin
    if (bypass) begin
        data_out = data_in;
    end else begin
        for (int i = 0; i < NUM_LANES; i++) begin
            int src = swizzle_map[i];
            data_out[i*DATA_WIDTH + (DATA_WIDTH-1):DATA_WIDTH-1] = data_in[src];
        end
    end
end

// Check parity for each lane when required
always @(*) begin
    if (ENABLE_PARITY_CHECK) begin
        parity_error = 0;
        for (int lane = 0; lane < NUM_LANES; lane++) begin
            int total = 0;
            for (int bit = 0; bit < DATA_WIDTH; bit++) begin
                total ^= data_out[lane*DATA_WIDTH + bit];
            end
            if (total != 0) begin
                parity_error = 1;
                break;
            end
        }
    end
end

// Pack the output lanes into a single flat bus
always @(*) begin
    if (!REGISTER_OUTPUT) begin
        data_out[0:DATA_WIDTH*NUM_LANES] = data_out;
    end
end

endmodule
