module hamming_rx #(parameter DATA_WIDTH = 4, parameter PARITY_BIT = 3) (
    input logic [ENCODED_DATA-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out
);

    logic [PARITY_BIT-1:0] parity;

    // Initialization
    initial begin
        parity = '0;
    end

    // Error Detection Using Even Parity Logic
    always_comb begin
        for (int i = 0; i < PARITY_BIT; i++) begin
            case (data_in[i])
                0: parity[i] = 1'b0;
                others: parity[i] = 1'b1;
            endcase
        end
    end

    // Error Correction
    always_comb begin
        if ({parity[PARITY_BIT-1:0] == 1'b0}) begin
            data_out = data_in;
        end else begin
            // Locate the error bit
            int error_pos = PARITY_BIT - 1;
            while (error_pos > 0 && parity[error_pos] == 0) begin
                error_pos = error_pos - 1;
            end

            // Correct the error by flipping the bit
            data_in[error_pos] = ~data_in[error_pos];
        end
    end

    // Output Assignment
    assign data_out = {data_in[3], data_in[5], data_in[6], data_in[7]};

endmodule
