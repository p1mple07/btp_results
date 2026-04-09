module hamming_tx #(
    // Parameters
    parameter DATA_WIDTH       = 4,
    parameter PART_WIDTH      = 4,
    parameter PARITY_BIT      = 3,
    parameter NUM_MODULES      = DATA_WIDTH / PART_WIDTH
)
(
    input  [DATA_WIDTH-1:0]    data_in,
    output [NUM_MODULES * (PARITY_BIT + DATA_WIDTH + 1)-1:0] data_out
);

    genvar i;

    // Calculate encoded data width
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1;
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA);

    // Initialize output
    reg [NUM_MODULES * ENCODED_DATA - 1:0] data_out = 0;

    // Process each module
    for (i = 0; i < NUM_MODULES; i = i + 1) begin
        // Extract slice for current module
        reg [PART_WIDTH-1:0] slice = data_in[(i * PART_WIDTH):((i * PART_WIDTH) + PART_WIDTH - 1)];

        // Process slice through Hamming transmitter
        reg [ENCODED_DATA-1:0] encoded_slice;
        reg [PARITY_BIT-1:0] parity;
        integer j, count;
        reg [ENCODED_DATA_BIT:0] pos;

        always @(*) begin
            encoded_slice = 0;
            parity = 0;
            count = 0;

            for (pos = 1; pos < ENCODED_DATA; pos = pos + 1) begin
                if ((pos & (pos - 1)) != 0) begin
                    encoded_slice[pos] = slice[count];
                    count = count + 1;
                end
            end

            for (j = 0; j < PARITY_BIT; j = j + 1) begin
                for (i = 1; i <= ENCODED_DATA-1; i = i + 1) begin
                    if ((i & (1 << j)) != 0) begin
                        parity[j] = parity[j] ^ encoded_slice[i];
                    end
                end
            end

            for (j = 0; j < PARITY_BIT; j = j + 1) begin
                encoded_slice[(1 << j)] = parity[j];
            end
        end

        // Update final output
        data_out = (data_out << ENCODED_DATA) | encoded_slice;
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
        parity   = 0;
        count    = 0;

        for (pos = 1; pos < ENCODED_DATA; pos = pos + 1) begin
            if ((pos & (pos - 1)) != 0) begin
                data_out[pos] = data_in[count];
                count = count + 1;
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