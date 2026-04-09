module hamming_tx #(
    // Top-level parameters
    parameter DATA_WIDTH = 64,       // Total width of data_in
    parameter PART_WIDTH = 4,        // Width of each data segment
    parameter PARITY_BIT = 3,        // Number of parity bits per segment
    // Derived parameters
    localparam ENCODED_DATA = PARITY_BIT + PART_WIDTH + 1,  // Width of each encoded segment
    localparam NUM_MODULES = DATA_WIDTH / PART_WIDTH,         // Number of t_hamming_tx instances
    localparam TOTAL_ENCODED = ENCODED_DATA * NUM_MODULES      // Total width of encoded output
)(
    input  [DATA_WIDTH-1:0] data_in,
    output reg [TOTAL_ENCODED-1:0] data_out
);

    // Array to hold the encoded output from each t_hamming_tx instance.
    wire [ENCODED_DATA-1:0] tx_out [0:NUM_MODULES-1];

    genvar i;
    generate
        for (i = 0; i < NUM_MODULES; i = i + 1) begin : gen_tx
            // Extract a PART_WIDTH-bit slice from data_in.
            // Instance 0 gets the least-significant bits.
            wire [PART_WIDTH-1:0] data_slice;
            assign data_slice = data_in[i*PART_WIDTH +: PART_WIDTH];

            // Instantiate t_hamming_tx for each slice.
            t_hamming_tx #(
                .DATA_WIDTH(PART_WIDTH),
                .PARITY_BIT(PARITY_BIT),
                .ENCODED_DATA(PARITY_BIT + PART_WIDTH + 1),
                .ENCODED_DATA_BIT($clog2(PARITY_BIT + PART_WIDTH + 1))
            ) u_t_hamming_tx (
                .data_in(data_slice),
                .data_out(tx_out[i])
            );
        end
    endgenerate

    // Concatenate the encoded outputs.
    // To preserve the input data order (least-significant slice first),
    // instance 0’s output (tx_out[0]) must appear in the least-significant bits
    // of data_out. Since concatenation places the leftmost signal in the MSB,
    // we reverse the order in the concatenation.
    integer k;
    always @(*) begin
        data_out = 0;
        for (k = 0; k < NUM_MODULES; k = k + 1) begin
            // Place tx_out[NUM_MODULES-1-k] at bit position (k * ENCODED_DATA)
            data_out = data_out | (tx_out[NUM_MODULES-1-k] << (k * ENCODED_DATA));
        end
    end

endmodule


module t_hamming_tx #(
    parameter DATA_WIDTH       = 4,   // Width of the data segment (m)
    parameter PARITY_BIT       = 3,   // Number of parity bits (p)
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,  // Total encoded width
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]       data_in,
    output reg [ENCODED_DATA-1:0] data_out
);

    reg [PARITY_BIT-1:0] parity;
    integer i, j, count;
    reg [ENCODED_DATA_BIT:0] pos;

    always @(*) begin
        // Initialize the encoded output and parity bits.
        data_out = {ENCODED_DATA{1'b0}};
        parity   = {PARITY_BIT{1'b0}};
        count    = 0;

        // Place data bits into non-parity positions.
        // Positions that are not powers of 2 are used for data.
        for (pos = 1; pos < ENCODED_DATA; pos = pos + 1) begin
            if (count < DATA_WIDTH) begin
                // Check if 'pos' is not a power of 2.
                if ((pos & (pos - 1)) != 0) begin
                    data_out[pos] = data_in[count];
                    count = count + 1;
                end
            end
        end

        // Calculate parity bits using even parity logic.
        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            for (i = 1; i <= ENCODED_DATA-1; i = i + 1) begin
                if ((i & (1 << j)) != 0) begin
                    parity[j] = parity[j] ^ data_out[i];
                end
            end
        end

        // Place the calculated parity bits into their designated positions.
        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            data_out[(1 << j)] = parity[j];
        end
    end

endmodule