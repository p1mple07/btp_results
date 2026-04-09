module hamming_tx #(
    parameter DATA_WIDTH = 4,
    parameter PARITY_BIT = 3
) (
    input [DATA_WIDTH-1:0] data_in,
    output [ENCODED_DATA_BIT-1:0] data_out
);

    localparam ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
    localparam ENCODED_DATA_BIT = bit_length(ENCODED_DATA);

    logic [DATA_WIDTH-1:0] data_out;
    logic [PARITY_BIT-1:0] parity;

    initial begin
        data_out[0] = 1'b0;
        for (int i = 0; i < DATA_WIDTH; i++) begin
            data_out[DATA_WIDTH + i] = data_in[i];
        end

        for (int n = 0; n < PARITY_BIT; n++) begin
            parity[n] = 0;
            for (int i = 0; i < ENCODED_DATA_BIT; i++) begin
                if ((i >> n) & 1) begin
                    parity[n] ^= data_out[i];
                end
            end
        end

        for (int n = 0; n < PARITY_BIT; n++) begin
            assign data_out[(1 << n)] = parity[n];
        end
    end

endmodule
