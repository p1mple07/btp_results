module hamming_tx #(parameter DATA_WIDTH = 4, PARITY_BIT = 3) (
    input [DATA_WIDTH-1:0] data_in,
    output [ENCODED_DATA-1:0] data_out
);
    logic [PARITY_BIT-1:0] parity;

    // Initialize parity to zero
    initial begin
        parity = '{1'b0, 1'b0, 1'b0, 1'b0};
    end

    // Step 2: Assign data_in to data_out
    assign data_out = '{1'b0, data_in[DATA_WIDTH-1], data_in[DATA_WIDTH-2], data_in[DATA_WIDTH-3], parity[0], parity[1], parity[2], 1'b0};

    // Step 3: Calculate the even parity bits based on the Hamming code principle
    always @* begin
        for (int i = 0; i < PARITY_BIT; i = i + 1) begin
            parity[i] = (data_out[2**i] ^ data_out[2**i + 1] ^ data_out[2**i + 2] ^ data_out[2**i + 3]) & 1'b1;
        end
    end

endmodule

// ENCODED_DATA and ENCODED_DATA_BIT are not directly set within the module.
// They should be calculated based on the DATA_WIDTH and PARITY_BIT parameters.
// For example, ENCODED_DATA = DATA_WIDTH + PARITY_BIT + 1
// ENCODED_DATA_BIT = ceil(log2(ENCODED_DATA))

// Example instantiation in a top-level design:
// hamming_tx #(.DATA_WIDTH(4), .PARITY_BIT(3)) hamming_tx_inst (
//     .data_in(data_in),
//     .data_out(data_out)
// );
