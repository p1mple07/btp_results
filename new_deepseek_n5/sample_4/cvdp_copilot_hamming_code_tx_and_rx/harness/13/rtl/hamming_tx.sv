module hamming_tx #(
    parameter DATA_WIDTH       = 64,
    parameter PART_WIDTH      = 4,
    parameter PARITY_BIT      = 3,
    parameter NUM_MODULES     = DATA_WIDTH / PART_WIDTH,
    parameter TOTAL_ENCODED   = NUM_MODULES * (PARITY_BIT + PART_WIDTH + 1)
) (
    input  [DATA_WIDTH-1:0]    data_in,
    output [TOTAL_ENCODED-1:0] data_out
);

    reg [PARITY_BIT + PART_WIDTH + 1 - 1:0] data_out_reg;
    reg [PARITY_BIT - 1:0] parity;
    integer i, j, count, module_index;

    always begin
        module_index = 0;
        count = 0;

        for (i = 0; i < NUM_MODULES; i = i + 1) begin
            // Extract the current module's slice from data_in
            data_out_reg = 0;
            for (j = 0; j < PART_WIDTH; j = j + 1) begin
                data_out_reg = data_out_reg | (data_in[(i * PART_WIDTH) + j] << (TOTAL_ENCODED - (i * (PART_WIDTH + PARITY_BIT + 1) + j)));
            end

            // Process the slice through t_hamming_tx
            t_hamming_tx #(
                DATA_WIDTH = PART_WIDTH,
                PARITY_BIT = PARITY_BIT
            ) instance_hamming_tx(.data_in(data_out_reg >> (TOTAL_ENCODED - (i * (PART_WIDTH + PARITY_BIT + 1)))), .data_out(t_hamming_tx.data_out))
            );

            // Update count and module_index
            count = 0;
            module_index = i + 1;
        end

        // Concatenate the results
        data_out = data_out_reg;
    end
endmodule

module t_hamming_tx #(
    parameter DATA_WIDTH       = 4,
    parameter PARITY_BIT       = 3,
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]       data_in,
    output  reg[ENCODED_DATA-1:0] data_out
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