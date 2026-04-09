module hamming_tx #(
    parameter DATA_WIDTH       = 64,
    parameter PART_WIDTH      = 4,
    parameter PARITY_BIT      = 3,
    parameter NUM_MODULES     = DATA_WIDTH / PART_WIDTH,
    parameter TOTAL_ENCODED   = (PARITY_BIT + PART_WIDTH + 1) * NUM_MODULES
) (
    input  [DATA_WIDTH-1:0]    data_in,
    output [TOTAL_ENCODED-1:0] data_out
);

    // Split data into chunks for each t_hamming_tx instance
    reg [PART_WIDTH-1:0] chunk;
    reg [NUM_MODULES-1:0] num instantiated;

    integer i, j, k;

    // Buffer to accumulate encoded data from all modules
    reg [TOTAL_ENCODED-1:0] encoded_buffer;

    always begin
        encoded_buffer = 0;

        for (i = 0; i < NUM_MODULES; i = i + 1) begin
            // Extract current chunk
            chunk = data_in[(PART_WIDTH * i) : (PART_WIDTH * (i + 1)) - 1];

            // Encode chunk using t_hamming_tx
            t_hamming_tx #(
                DATA_WIDTH = PART_WIDTH,
                PARITY_BIT  = PARITY_BIT,
                ENCODED_DATA = PARITY_BIT + PART_WIDTH + 1
            ) instance t Instance (
                data_in  : chunk,
                data_out : temp_out
            );

            // Concatenate encoded output to buffer
            encoded_buffer = encoded_buffer | temp_out;
        end

        // Assign final output
        data_out = encoded_buffer;
    end
endmodule

module t_hamming_tx #(
    parameter DATA_WIDTH,
    parameter PARITY_BIT,
    parameter ENCODED_DATA
) (
    input  [DATA_WIDTH-1:0]       data_in,
    output reg[ENCODED_DATA-1:0] data_out
);

    // Calculate number of parity bits if not provided
    reg int p;
    if (PARITY_BIT == 0) begin
        p = 0;
        while (1 << p) < (DATA_WIDTH + p + 1) begin
            p = p + 1;
        end
        PARITY_BIT = p;
    end

    // Calculate positions for parity bits
    reg int pos;
    integer i, j;

    always begin
        // Initialize output
        data_out = 0;

        // Assign data bits
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            data_out[i] = data_in[i];
        end

        // Calculate parity bits
        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            pos = 1 << j;
            for (i = 1; i <= ENCODED_DATA; i = i + 1) begin
                if (i & pos) begin
                    data_out[pos] = data_out[pos] ^ data_out[i];
                end
            end
        end

        // Assign parity bits to their positions
        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            data_out[(1 << j)] = data_out[(1 << j) + DATA_WIDTH];
        end
    end
endmodule