`timescale 1ns / 1ps

module swizzler #(
    parameter integer NUM_LANES = 4,
    parameter integer DATA_WIDTH = 8,
    parameter integer REGISTER_OUTPUT = 0,
    parameter integer ENABLE_PARITY_CHECK = 0
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          bypass,
    input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
    input  wire [NUM_LANES*$clog2(NUM_LANES)-1:0] swizzle_map_flat,
    output reg  [NUM_LANES*DATA_WIDTH-1:0] data_out,
    output reg           parity_error
);

    // Internal signals
    logic [NUM_LANES*DATA_WIDTH-1:0] data_out_temp;
    logic [NUM_LANES*$clog2(NUM_LANES)-1:0] output_lanes;
    logic [NUM_LANES*DATA_WIDTH-1:0] parity_bits;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            data_out_temp <= {NUM_LANES{1'b0}};
            output_lanes <= {NUM_LANES{1'b0}};
            parity_error <= 1'b0;
        end else begin
            // Unpack data_in into lanes
            // We'll assume data_in is already unpacked, so we just use it as is.
            data_out_temp = data_in;
            // Apply mapping: swizzle_map
            output_lanes = data_out_temp;
            // Parity check
            if (ENABLE_PARITY_CHECK)
                parity_error = any(data_out_temp);
        end
    end

    assign output_lanes = data_out_temp;

    // Output packing
    assign data_out = output_lanes;

    // Output register
    if (REGISTER_OUTPUT)
        always_ff @(posedge clk) begin
            data_out <= output_lanes;
            parity_error <= any(output_lanes);
        end
    else
        data_out <= output_lanes;
        parity_error <= any(output_lanes);
endfunction

endmodule
