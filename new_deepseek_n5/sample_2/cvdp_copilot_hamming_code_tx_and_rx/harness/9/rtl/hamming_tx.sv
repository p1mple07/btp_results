module hamming_tx_for_4bit(
  input[3:0] data_in,
  output[7:0] data_out
);

parameters
  DATA_WIDTH = 4;
  PARITY_BIT = 3;

reg [((ENCODED_DATA_BIT) - 1):0] parity[PARITY_BIT:0];
reg [((ENCODED_DATA) - 1):0] data_out;

// Calculate encoded data size and bit-width
ENCODED_DATA = DATA_WIDTH + PARITY_BIT + 1;
ENCODED_DATA_BIT = (ENCODED_DATA - 1).bit_length();

// Data bits positions (excluding parity and redundant bits)
reg data_bits_pos[DATA_WIDTH:0];
integer pos = 3;
for (int i = 0; i < DATA_WIDTH; i++) {
    while (1) {
        if (pos != 0 && (pos & (pos - 1)) != 0) {
            data_bits_pos[i] = pos;
            break;
        }
        pos++;
    }
}

// Assign data_in to data_out
data_out[0] = 0;
for (int i = 0; i < DATA_WIDTH; i++) {
    data_out[data_bits_pos[i]] = data_in[i];
}

// Calculate parity bits
for (int n = 0; n < PARITY_BIT; n++) {
    integer mask = 1 << n;
    reg parity_bit = 0;
    for (int i = 0; i < ENCODED_DATA; i++) {
        if ((i & mask) != 0) {
            parity_bit ^= data_out[i];
        }
    }
    parity[n] = parity_bit;
}

// Assign parity bits to data_out
reg pos_parity[PARITY_BIT:0];
pos_parity[0] = 1;
for (int n = 1; n < PARITY_BIT; n++) {
    pos_parity[n] = pos_parity[n - 1] * 2;
}
for (int n = 0; n < PARITY_BIT; n++) {
    data_out[pos_parity[n]] = parity[n];
}

endmodule