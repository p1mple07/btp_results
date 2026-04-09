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

    // Reset
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            data_out <= {NUM_LANES{1'b0}};
            parity_error <= 0;
        end else begin
            data_out <= {NUM_LANES{1'b0}};
        end
    end

    // Unpack data_in
    always @(posedge clk) begin
        if (!bypass) begin
            for (int i = 0; i < NUM_LANES; i++) begin
                data_in_unpacked[i] = data_in[(i+1)*DATA_WIDTH-1 - : DATA_WIDTH];
            end
        end
    end

    // Map swizzle map to output lanes
    always @(posedge clk) begin
        if (!bypass) begin
            for (int j = 0; j < NUM_LANES; j++) begin
                int src_lane = swizzle_map[j];
                int dst_lane = (j+1)*DATA_WIDTH - 1 : DATA_WIDTH;
                data_out[dst_lane] = data_in_unpacked[src_lane];
            end
        end
    end

    // Parity check
    always @(posedge clk) begin
        if (!bypass && !parity_error) begin
            parity_error = 0;
            for (int i = 0; i < NUM_LANES; i++) begin
                int bit = 1 << (data_out[i] >> 7);
                parity_error = parity_error | bit;
            end
        end
    end

    // Output register
    always @(posedge clk) begin
        if (REGISTER_OUTPUT) begin
            data_out_reg <= data_out;
        end
    end

endmodule
