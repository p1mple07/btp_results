module hamming_tx #(
    parameter DATA_WIDTH       = 64,
    parameter PART_WIDTH       = 4,
    parameter PARITY_BIT       = $clog2(DATA_WIDTH / PART_WIDTH + 1),
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)(
    input  [DATA_WIDTH-1:0]    data_in,
    output [ENCODED_DATA-1:0] data_out
);

    genvar i;

    // Splitting data_in into segments and creating t_hamming_tx instances
    generate
        for (i = 0; i < DATA_WIDTH / PART_WIDTH; i = i + 1) begin : split_data_in
            assign data_in[(i+1)*PART_WIDTH-1:i*PART_WIDTH] = data_in[(i+1)*PART_WIDTH-1:i*PART_WIDTH];
        end

        // Creating t_hamming_tx instances
        t_hamming_tx u_t_hamming_tx_inst (
            .data_in(data_in[(i+1)*PART_WIDTH-1:i*PART_WIDTH]),
            .data_out(data_out[(i+1)*ENCODED_DATA-1:i*ENCODED_DATA])
        );
    endgenerate

endmodule
