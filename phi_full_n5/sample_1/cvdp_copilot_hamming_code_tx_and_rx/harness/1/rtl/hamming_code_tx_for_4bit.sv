module hamming_code_tx_for_4bit (
    input [3:0] data_in,
    output reg [7:0] data_out
);

    // Step 1: Set the least significant bit to 0
    assign data_out[0] = 0;

    // Step 2: Calculate parity bit for positions 0, 1, 3
    assign data_out[1] = (data_in[0] ^ data_in[1] ^ data_in[3]) | 1;

    // Step 3: Calculate parity bit for positions 0, 2, 3
    assign data_out[2] = (data_in[0] ^ data_in[2] ^ data_in[3]) | 1;

    // Step 4: Calculate parity bit for positions 1, 2, 3
    assign data_out[4] = (data_in[1] ^ data_in[2] ^ data_in[3]) | 1;

    // Step 5: Assign the original data bits in order
    assign data_out[3] = data_in[0];
    assign data_out[5] = data_in[1];
    assign data_out[6] = data_in[2];
    assign data_out[7] = data_in[3];

endmodule
