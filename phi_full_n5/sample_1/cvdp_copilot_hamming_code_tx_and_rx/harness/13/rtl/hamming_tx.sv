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

    generate
        for (i = 0; i < (DATA_WIDTH + PART_WIDTH - 1) / PART_WIDTH; i = i + 1) begin
            t_hamming_tx instance_name_(.DATA_WIDTH(PART_WIDTH), .PARITY_BIT(PARITY_BIT), .ENCODED_DATA(ENCODED_DATA));
            assign data_out[(i * ENCODED_DATA) +: ENCODED_DATA] = instance_name_inst.data_out;
        end
    endgenerate

endmodule
