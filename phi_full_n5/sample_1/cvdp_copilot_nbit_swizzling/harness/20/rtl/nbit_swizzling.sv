module nbit_swizzling #(parameter DATA_WIDTH = 16) (
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out
);

integer i, j;
wire parity_bits[PARITY_BITS-1:0];

// Calculate parity bits and encode data_in into ecc_out
always @(*) begin
    parity_bits = {(1'b0)}; // Initialize parity_bits with zeros
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
        parity_bits[PARITY_BITS-1-i] = ^data_in[i]; // Compute parity bits using XOR
    end

    // Place data_in bits into ecc_out, skipping parity bit positions
    for (j = 0; j < DATA_WIDTH; j = j + 1) begin
        if (j < PARITY_BITS) begin
            ecc_out[j] = data_in[j];
        end else begin
            ecc_out[j] = data_in[j - PARITY_BITS];
        end
    end
end

endmodule