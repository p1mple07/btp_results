module hamming_tx #(
    parameter DATA_WIDTH    = 64,
    parameter PART_WIDTH    = 4,
    parameter PARITY_BIT    = 3,
    parameter ENCODED_DATA  = PARITY_BIT + PART_WIDTH + 1,
    parameter NUM_MODULES   = DATA_WIDTH / PART_WIDTH,
    parameter TOTAL_ENCODED = ENCODED_DATA * NUM_MODULES
)(
    input  [DATA_WIDTH-1:0] data_in,
    output [TOTAL_ENCODED-1:0] data_out
);

    genvar j;
    // Array to hold the encoded output from each t_hamming_tx instance.
    wire [ENCODED_DATA-1:0] encoded_modules [0:NUM_MODULES-1];

    generate
        for (j = 0; j < NUM_MODULES; j = j + 1) begin : gen_t_hamming_tx
            t_hamming_tx #(
                .DATA_WIDTH(PART_WIDTH),
                .PARITY_BIT(PARITY_BIT)
            ) u_t_hamming_tx (
                .data_in(data_in[j*PART_WIDTH +: PART_WIDTH]),
                .data_out(encoded_modules[j])
            );
        end
    endgenerate

    // Concatenate the outputs from each instance.
    // The input data order is preserved: the least significant slice (j=0)
    // becomes the least significant part of data_out. In a concatenation expression,
    // the leftmost operand is the MSB. Therefore, we reverse the order.
    reg [TOTAL_ENCODED-1:0] data_out_reg;
    integer k;
    always_comb begin
        data_out_reg = '0;
        // Loop from the highest index to 0 so that encoded_modules[NUM_MODULES-1] becomes MSB.
        for (k = NUM_MODULES - 1; k >= 0; k = k - 1) begin
            data_out_reg[k*ENCODED_DATA +: ENCODED_DATA] = encoded_modules[k];
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

        // Place the data bits into non-parity positions.
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

        // Place the calculated parity bits in their positions.
        for (j = 0; j < PARITY_BIT; j = j + 1) begin
            data_out[(1 << j)] = parity[j];
        end
    end

endmodule