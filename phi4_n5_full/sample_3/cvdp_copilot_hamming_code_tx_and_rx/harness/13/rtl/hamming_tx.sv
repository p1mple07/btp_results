module hamming_tx #(
    parameter DATA_WIDTH    = 64,
    parameter PART_WIDTH    = 4,
    parameter PARITY_BIT    = 3,
    parameter ENCODED_DATA  = PARITY_BIT + PART_WIDTH + 1,
    parameter NUM_MODULES   = DATA_WIDTH / PART_WIDTH,
    parameter TOTAL_ENCODED = NUM_MODULES * ENCODED_DATA
)(
    input  [DATA_WIDTH-1:0] data_in,
    output [TOTAL_ENCODED-1:0] data_out
);

    genvar i;
    // Array to hold the encoded output from each t_hamming_tx instance.
    // Instance 0 processes the lowest-order PART_WIDTH bits of data_in.
    wire [ENCODED_DATA-1:0] encoded_seg [0:NUM_MODULES-1];

    generate
        for (i = 0; i < NUM_MODULES; i = i + 1) begin : gen_tx
            // Each instance gets a slice of data_in:
            // data_in[i*PART_WIDTH +: PART_WIDTH] extracts the PART_WIDTH bits starting at bit i*PART_WIDTH.
            t_hamming_tx #(
                .DATA_WIDTH(PART_WIDTH),
                .PARITY_BIT(PARITY_BIT),
                .ENCODED_DATA(PARITY_BIT + PART_WIDTH + 1)
            ) inst_t_hamming_tx (
                .data_in(data_in[i*PART_WIDTH +: PART_WIDTH]),
                .data_out(encoded_seg[i])
            );
        end
    endgenerate

    // Reconstruct the final encoded output by concatenating the outputs of each instance.
    // Since instance 0 processes the lowest-order bits, its output must appear as the least significant bits.
    // Therefore, we reverse the order of the array when concatenating.
    reg [TOTAL_ENCODED-1:0] data_out_reg;
    integer k;
    always_comb begin
        data_out_reg = '0;
        for (k = 0; k < NUM_MODULES; k = k + 1) begin
            // Place the encoded segment from the corresponding instance into the proper slice of data_out_reg.
            // Note: We use NUM_MODULES-1-k so that instance 0 (lowest-order) becomes the LSB of data_out.
            data_out_reg[(k+1)*ENCODED_DATA-1 : k*ENCODED_DATA] = encoded_seg[NUM_MODULES-1 - k];
        end
    end
    assign data_out = data_out_reg;

endmodule

module t_hamming_tx #(
    parameter DATA_WIDTH       = 4,
    parameter PARITY_BIT       = 3,
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0] data_in,
    output reg [ENCODED_DATA-1:0] data_out
);

    reg [PARITY_BIT-1:0] parity;
    integer i, j, count;
    reg [ENCODED_DATA_BIT:0] pos;

    always @(*) begin
        data_out = {ENCODED_DATA{1'b0}};
        parity   = {PARITY_BIT{1'b0}};
        count    = 0;

        // Place data bits in non-power-of-2 positions.
        for (pos = 1; pos < ENCODED_DATA; pos = pos + 1) begin
            if (count < DATA_WIDTH) begin
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