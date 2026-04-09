module hamming_tx #(
    parameter DATA_WIDTH       = 64,
    parameter PART_WIDTH       = 4,
    parameter PARITY_BIT       = $clog2((DATA_WIDTH + PART_WIDTH - 1) / PART_WIDTH),
    parameter ENCODED_DATA     = PARITY_BIT + PART_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]    data_in,
    output [ENCODED_DATA-1:0] data_out
);

    genvar i;

    // Split data_in into PART_WIDTH segments and instantiate t_hamming_tx for each segment
    generate
        for (i = 0; i < (DATA_WIDTH + PART_WIDTH - 1) / PART_WIDTH; i = i + 1) begin
            assign data_in_seg[i] = data_in[(i * PART_WIDTH)-1:PART_WIDTH-1];
            t_hamming_tx #(.DATA_WIDTH(PART_WIDTH), .PARITY_BIT(PARITY_BIT),
                          .ENCODED_DATA(PART_WIDTH + PARITY_BIT + 1))
                          (
                            .data_in(data_in_seg[i]),
                            .data_out(data_out[(i * (PART_WIDTH + PARITY_BIT + 1))-1:0])
                          );
        end
    endgenerate

endmodule


module t_hamming_tx #(
    parameter DATA_WIDTH       = 4,
    parameter PARITY_BIT       = 3,
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]       data_in,
    output [ENCODED_DATA-1:0] data_out
);

    reg [PARITY_BIT-1:0] parity;
    integer i, j, count;
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
