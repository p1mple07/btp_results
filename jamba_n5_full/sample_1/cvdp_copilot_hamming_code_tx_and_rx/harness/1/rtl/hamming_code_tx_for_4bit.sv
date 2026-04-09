module hamming_code_tx_for_4bit(input [3:0] data_in, output reg [7:0] data_out);

always_ff @(input data_in) begin
    reg [1:0] parity;

    // Data Out Bit 0 is redundant (0)
    data_out[0] = 0;

    // Parity bit 1: positions 0,1,3
    parity = data_in[0] ^ data_in[1] ^ data_in[3];
    data_out[1] = parity;

    // Parity bit 2: positions 0,2,3
    parity = data_in[0] ^ data_in[2] ^ data_in[3];
    data_out[2] = parity;

    // Parity bit 4: positions 1,2,3
    parity = data_in[1] ^ data_in[2] ^ data_in[3];
    data_out[4] = parity;

    // Set remaining bits
    data_out[3] = data_in[0];
    data_out[5] = data_in[1];
    data_out[6] = data_in[2];
    data_out[7] = data_in[3];

end
