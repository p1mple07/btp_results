module hamming_tx #(
    parameter DATA_WIDTH       = 4,
    parameter PART_WIDTH      = 4,
    parameter PARITY_BIT      = 3,
    parameter ENCODED_DATA    = PARITY_BIT + PART_WIDTH + 1,
    parameter NUM_MODULES      = DATA_WIDTH / PART_WIDTH,
    parameter TOTAL_ENCODED   = ENCODED_DATA * NUM_MODULES
)(
    input  [DATA_WIDTH-1:0]    data_in,
    output [TOTAL_ENCODED-1:0] data_out
);

    genvar i;

    reg [ENCODED_DATA-1:0] data_out_reg;
    reg [PARITY_BIT-1:0]  parity_reg;
    reg [NUM_MODULES-1:0]  module_index;
    reg [TOTAL_ENCODED-1:0] pos;

    always @(*) begin
        pos = 0;
        module_index = 0;

        for (i = 0; i < NUM_MODULES; i = i + 1) begin
            // Extract slice for current module
            reg [PART_WIDTH-1:0] slice;
            for (j = 0; j < PART_WIDTH; j = j + 1) begin
                slice[j] = data_in[(i * PART_WIDTH) + j];
            end

            // Call t_hamming_tx implementation
            t_hamming_tx #(
                DATA_WIDTH = PART_WIDTH,
                PARITY_BIT  = PARITY_BIT,
                ENCODED_DATA = ENCODED_DATA
            ) instance(
                data_in = slice,
                data_out = parity_reg
            );

            // Concatenate output
            for (j = 0; j < ENCODED_DATA; j = j + 1) begin
                if (j < PART_WIDTH) begin
                    data_out_reg[j] = parity_reg[j];
                end else if (j < ENCODED_DATA) begin
                    data_out_reg[j] = data_in[(i * PART_WIDTH) + (j - PART_WIDTH)];
                end
            end

            // Move to next module
            module_index = module_index + 1;
        end

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
        data_out = 0;
        parity = 0;
        count    = 0;

        for (pos = 0; pos < ENCODED_DATA; pos = pos + 1) begin
            if (count < DATA_WIDTH) begin
                data_out[pos] = data_in[count];
                count = count + 1;
            end
        end

        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            for (i = 1; i <= ENCODED_DATA; i = i + 1) begin
                if ((i & (1 << j)) != 0) begin
                    data_out[i] = data_out[i] ^ data_out[i ^ (1 << j)];
                end
            end
        end

        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            data_out[(1 << j)] = parity[j];
        end
    end
endmodule