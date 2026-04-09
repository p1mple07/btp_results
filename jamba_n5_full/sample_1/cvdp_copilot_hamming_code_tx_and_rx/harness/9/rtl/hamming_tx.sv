module hamming_tx #(
    parameter DATA_WIDTH = 4,
    parameter PARITY_BIT = 3
) (
    input [DATA_WIDTH-1:0] data_in,
    output [ENCODED_DATA_BIT-1:0] data_out
);

    localparam PARITY_COUNT = PARITY_BIT;
    localparam ENCODED_DATA = PARITY_COUNT + DATA_WIDTH + 1;
    localparam ENCODED_DATA_BIT = $clog2(ENCODED_DATA);

    reg [DATA_WIDTH-1:0] data_out_reg;
    reg [PARITY_COUNT-1:0] parity;

    initial begin
        data_out_reg = 0;
        for (int i = 0; i < ENCODED_DATA_BIT; i++) begin
            data_out_reg[i] = 1'b0;
        end
    end

    always @(*) begin
        data_out_reg = data_out_reg;

        // Place parity bits at positions that are powers of two.
        for (int n = 0; n < PARITY_COUNT; n++) begin
            int parity_index = 2 ** n;
            if (parity_index < ENCODED_DATA_BIT) begin
                parity[n] = data_in[parity_index];
            end
        end

        // Insert parity bits into the output register.
        for (int n = 0; n < PARITY_COUNT; n++) begin
            int data_out_index = 2 ** n;
            if (data_out_index < ENCODED_DATA_BIT) begin
                data_out_reg[data_out_index] = parity[n];
            end
        end

        data_out = data_out_reg;
    end

endmodule
