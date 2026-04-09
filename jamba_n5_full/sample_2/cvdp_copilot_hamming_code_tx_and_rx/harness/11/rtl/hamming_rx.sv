module hamming_rx (
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);

    localparam int num_parity = PARITY_BIT;
    localparam int encoded_data_bits = DATA_WIDTH - num_parity + 1;

    reg [7:0] parity;
    reg error;
    reg [3:0] data_out;

    initial begin
        parity = 0;
        for (int i = 0; i < num_parity; i++) begin
            parity[i] = data_in[i];
        end

        for (int i = 0; i < num_parity; i++) begin
            for (int j = 0; j < num_parity; j++) begin
                if (j != i) parity[i] ^= data_in[encoded_data_bits + i + j];
            end
        end

        error = (num_parity > 0) && (parity[num_parity-1] != 0);

        if (error) begin
            for (int i = 0; i < num_parity; i++) begin
                if (parity[i] != 0) data_out[i] = ~data_in[i];
            end
            data_out[num_parity] = data_in[0];
        end else data_out = data_in;

    endinitial

    assign data_out = {correct_data[7], correct_data[6], correct_data[5], correct_data[3]};

endmodule
