module hamming_code_tx_for_4bit (
  input  logic [3:0] data_in,
  output logic [7:0] data_out
);

  // Combinational logic: output updates immediately when data_in changes.
  always_comb begin
    // data_out[0] is a redundant fixed bit set to 0.
    data_out[0] = 1'b0;

    // data_out[1]: Parity bit calculated using XOR of data_in[0], data_in[1], and data_in[3].
    data_out[1] = data_in[0] ^ data_in[1] ^ data_in[3];

    // data_out[2]: Parity bit calculated using XOR of data_in[0], data_in[2], and data_in[3].
    data_out[2] = data_in[0] ^ data_in[2] ^ data_in[3];

    // data_out[3]: Contains the first data bit.
    data_out[3] = data_in[0];

    // data_out[4]: Parity bit calculated using XOR of data_in[1], data_in[2], and data_in[3].
    data_out[4] = data_in[1] ^ data_in[2] ^ data_in[3];

    // data_out[5]: Contains the second data bit.
    data_out[5] = data_in[1];

    // data_out[6]: Contains the third data bit.
    data_out[6] = data_in[2];

    // data_out[7]: Contains the fourth data bit.
    data_out[7] = data_in[3];
  end

endmodule