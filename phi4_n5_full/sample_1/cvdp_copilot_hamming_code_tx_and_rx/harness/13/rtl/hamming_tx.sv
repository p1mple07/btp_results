module hamming_tx #(
    // Top-level parameters
    parameter DATA_WIDTH = 64,      // Total width of the input data (must be > 0 and divisible by PART_WIDTH)
    parameter PART_WIDTH = 4,       // Width of each data segment for t_hamming_tx
    parameter PARITY_BIT = 3        // Number of parity bits per t_hamming_tx instance
)(
    input  [DATA_WIDTH-1:0] data_in,
    output reg [TOTAL_ENCODED-1:0] data_out
);

    // Derived parameters
    localparam NUM_MODULES   = DATA_WIDTH / PART_WIDTH;   // Number of t_hamming_tx instances
    localparam ENCODED_DATA  = PARITY_BIT + PART_WIDTH + 1; // Each instance outputs this many bits
    localparam TOTAL_ENCODED = NUM_MODULES * ENCODED_DATA;  // Total output width

    genvar i;
    // Declare an array of wires to collect each instance's encoded output
    wire [ENCODED_DATA-1:0] tx_out [NUM_MODULES-1:0];

    // Generate NUM_MODULES instances of t_hamming_tx.
    // Each instance processes a PART_WIDTH-bit slice of data_in, starting from the least significant bits.
    generate
        for (i = 0; i < NUM_MODULES; i = i + 1) begin : tx_gen
            t_hamming_tx #(
                .DATA_WIDTH(PART_WIDTH),  // Override the default DATA_WIDTH to match PART_WIDTH
                .PARITY_BIT(PARITY_BIT)
            ) u_t_hamming_tx (
                .data_in(data_in[i*PART_WIDTH +: PART_WIDTH]),
                .data_out(tx_out[i])
            );
        end
    endgenerate

    // Concatenate the outputs from all instances.
    // The lowest-order slice (i=0) should appear at the least significant bits of data_out.
    // Therefore, we reverse the order of the instance outputs in the final concatenation.
    always_comb begin
        data_out = '0;
        for (i = 0; i < NUM_MODULES; i = i + 1) begin
            // Instance at index (NUM_MODULES-1-i) is placed at the lower bits.
            data_out[i*ENCODED_DATA +: ENCODED_DATA] = tx_out[NUM_MODULES-1-i];
        end
    end

endmodule


module t_hamming_tx #(
    parameter DATA_WIDTH       = 4,
    parameter PARITY_BIT       = 3,
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]       data_in,
    output reg [ENCODED_DATA-1:0] data_out
);

    reg [PARITY_BIT-1:0] parity;
    integer i, j;
    reg [ENCODED_DATA_BIT:0] pos;

    always @(*) begin
        data_out = {ENCODED_DATA{1'b0}};
        parity   = {PARITY_BIT{1'b0}};
        integer count;
        count = 0;

        // Place data bits in non-parity positions.
        for (pos = 1; pos < ENCODED_DATA; pos = pos + 1) begin
            if (count < DATA_WIDTH) begin
                if ((pos & (pos - 1)) != 0) begin
                    data_out[pos] = data_in[count];
                    count = count + 1;
                end
            end
        end

        // Calculate parity bits using even parity.
        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            for (i = 1; i <= ENCODED_DATA-1; i = i + 1) begin
                if ((i & (1 << j)) != 0) begin
                    parity[j] = parity[j] ^ data_out[i];
                end
            end
        end

        // Place the calculated parity bits into their respective positions.
        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            data_out[(1 << j)] = parity[j];
        end
    end

endmodule