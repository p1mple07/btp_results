module hamming_tx #(
    parameter DATA_WIDTH       = 64,
    parameter PART_WIDTH       = 4,
    parameter PARITY_BIT       = 3,
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]    data_in,
    output [TOTAL_ENCODED-1:0] data_out
);

    genvar i;

    // Instantiate the t_hamming_tx instances
    localparam int num_modules = DATA_WIDTH / PART_WIDTH;
    for (int j = 0; j < num_modules; j++) begin : block
        assign data_out = {ENCODED_DATA{1'b0}};
        assign data_out[TOTAL_ENCODED-1: TOTAL_ENCODED - ENCODED_DATA] = data_in[j*PART_WIDTH : (j+1)*PART_WIDTH];
        assign data_out[ENCODED_DATA : ENCODED_DATA + PARITY_BIT] = parity;
    end

endmodule

module t_hamming_tx #(
    parameter DATA_WIDTH       = 4,
    parameter PARITY_BIT       = 3,
    parameter ENCODED_DATA     = 8,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]       data_in,
    output  reg[ENCODED_DATA-1:0] data_out
);

    reg [PARITY_BIT-1:0] parity;
    reg [ENCODED_DATA_BIT:0] pos;

    always @(*) begin
        data_out = {ENCODED_DATA{1'b0}};
        parity   = {PARITY_BIT{1'b0}};
        count    = 0;

        for (pos = 1; pos < ENCODED_DATA; pos = pos + 1) begin
            if (count < DATA_WIDTH) begin
                if ((pos & (pos - 1)) != 0) begin
                    data_out[pos] = data_in[count];
                    count = count + 1;
                end
            end
        end

        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            for (i = 1; i <= ENCODED_DATA-1; i = i + 1) begin
                if ((i & (1 << j)) != 0) begin
                    parity[j] = parity[j] ^ data_out[i];
                end
            end
        end

        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            data_out[(1 << j)] = parity[j];
        end
    end

endmodule
