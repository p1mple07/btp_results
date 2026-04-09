module hamming_rx #(parameter DATA_WIDTH = 4, parameter PARITY_BIT = 3) (
    input logic [ENCODED_DATA-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out
);

    logic [PARITY_BIT-1:0] parity;

    // Initialization
    initial begin
        parity = '{14'b0}; // Clear parity array
    end

    // Error detection and correction
    always_comb begin
        // Calculate parity bits using even parity logic
        for (int i = 0; i < PARITY_BIT; i++) begin
            case (data_in[i])
                3'b000: parity[i] = 1'b0;
                3'b001: parity[i] = 1'b0;
                3'b010: parity[i] = 1'b0;
                3'b011: parity[i] = 1'b0;
                3'b100: parity[i] = 1'b0;
                3'b101: parity[i] = 1'b0;
                3'b110: parity[i] = 1'b0;
                3'b111: parity[i] = 1'b0;
                default: parity[i] = 1'b0;
            endcase
        end

        // Error detection code
        logic error_detected;
        error_detected = ^parity; // XOR all parity bits

        // Error correction
        if (error_detected) begin
            // Determine error position
            logic [PARITY_BIT-1:0] error_pos;
            error_pos = {parity[PARITY_BIT-1:0], 1'b0}; // Add a 0 for least significant bit
            error_pos = {error_pos[PARITY_BIT-1], error_pos[PARITY_BIT-2], error_pos[PARITY_BIT-3], 1'b0}; // Shift left to get the correct error position

            // Correct the error by inverting the bit at the error position
            data_in[error_pos] = ~data_in[error_pos];
        end
        else begin
            // No error, copy data_in to data_out
            data_out = data_in[DATA_WIDTH-1:0];
        end
    end

endmodule
