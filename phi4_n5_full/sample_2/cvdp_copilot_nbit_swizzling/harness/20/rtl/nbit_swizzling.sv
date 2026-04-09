module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input  [DATA_WIDTH-1:0] data_in,
    input  [1:0]            sel,
    output reg [DATA_WIDTH:0] data_out,
    output reg [DATA_WIDTH + PARITY_BITS:0] ecc_out
);

    // Local parameter: number of parity bits computed as per specification
    localparam integer PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);

    // Original parity bit for data_out extension
    wire parity_bit;
    assign parity_bit = ^data_in;

    // Compute both ecc_out and swizzled data_out in one always block
    always @(*) begin
        // Total number of bits in the encoded output (data bits + parity bits)
        integer total_bits;
        total_bits = DATA_WIDTH + PARITY_BITS;

        // Temporary array to hold computed parity bits.
        // Index 0 corresponds to parity for position 1 (2^0),
        // index 1 for position 2 (2^1), index 2 for position 4 (2^2), etc.
        integer parity_val [0:PARITY_BITS-1];

        // Loop over each parity position p that is a power of 2 (1, 2, 4, 8, ...)
        integer p, i, j, k;
        for (p = 1; p <= total_bits; p = p * 2) begin
            bit parity = 1'b0;
            k = 0;
            // Iterate over all positions (0-indexed) in the final code word
            // Note: positions are considered as (j+1) in 1-indexing.
            for (j = 0; j < total_bits; j = j + 1) begin
                // If (j+1) is NOT a power of 2 then this position holds a