module swizzler #(
    parameter integer NUM_LANES = 4,
    parameter integer DATA_WIDTH = 8,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_PARITY_CHECK = 0
)(
    input  wire          clk,
    input  wire          rst_n,
    input  wire          bypass,
    input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
    input  wire [NUM_LANES*$clog2(NUM_LANES)-1:0] swizzle_map_flat,
    output reg          [NUM_LANES*DATA_WIDTH-1:0] data_out,
    output reg           parity_error
);

// internal variables
reg [NUM_LANES-1:0] mapped_data;
reg [NUM_LANES*$clog2(NUM_LANES)-1:0] output_data;
reg [NUM_LANES-1:0] current_bit;
reg [NUM_LANES*DATA_WIDTH-1:0] data_in_flattened;

always @(*) begin
    // unpack data_in into array of lanes
    for (int i = 0; i < NUM_LANES; i++) begin
        data_in_flattened[(i+1)*DATA_WIDTH-1 - : DATA_WIDTH] = data_in[i*DATA_WIDTH];
    end
end

always @(*) begin
    // flatten swizzle_map_flat to array
    for (int i = 0; i < NUM_LANES; i++) begin
        current_bit = swizzle_map_flat[(i+1)*NUM_LANES - 1 - : $clog2(NUM_LANES)];
        mapped_data[i] = current_bit;
    end
end

always @(posedge clk) begin
    if (bypass) begin
        data_out = data_in;
    end else begin
        // apply swizzle map
        for (int i = 0; i < NUM_LANES; i++) begin
            output_data[i] = mapped_data[i];
        end
    end
end

always @(posedge clk) begin
    if (enable_parity_check) begin
        parity_error = 0;
        for (int i = 0; i < NUM_LANES; i++) begin
            // compute parity of output_data[i]
            // simple XOR parity
            current_parity = 0;
            for (int j = 0; j < DATA_WIDTH; j++) begin
                current_parity ^= (output_data[i] >> j) & 1;
            end
            if (current_parity != 0) begin
                parity_error = 1;
                break;
            }
        end
    end
end

endmodule
