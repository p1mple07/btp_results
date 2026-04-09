module hamming_code_tx_for_4bit (
    input [3:0] data_in,
    output reg [7:0] data_out
);

    // Calculate parity bits
    wire c1, c2, c3;

    // Parity bit for positions 0, 1, 3
    assign c1 = data_in[0] ^ data_in[1] ^ data_in[3];
    // Parity bit for positions 0, 2, 3
    assign c2 = data_in[0] ^ data_in[2] ^ data_in[3];
    // Parity bit for positions 1, 2, 3
    assign c3 = data_in[1] ^ data_in[2] ^ data_in[3];

    // Assign values to data_out
    assign data_out[7:4] = {c3, c2, c1}; // Syndrome bits
    assign data_out[3:0] = {data_in[0], data_in[1], data_in[2], data_in[3]}; // Original data bits
    assign data_out[0] = 0; // Redundant bit

endmodule
