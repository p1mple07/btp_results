// Implement the one-hot encoding logic
assign exp_oh[23:12] = num_i[23:12].

// Use the `onehot_to_bin` module to convert the one-hot vector (`exp_oh`) into a binary exponent (`exp_bin`).
onehot_to_bin #(
 .ONE_HOT_W(12),
 .BIN_W(4)
) exp_oh_bin (
 .oh_vec_i(exp_oh[11:0]),
 .bin_vec_o(exp_bin[3:0])
);

// Extract the 12-bit mantissa using the calculated `exponent`:
assign mantissa = (|exp_oh)? {exp_oh[11:0], 4'b0} : {exp_oh[11:0], num_i[23:0]}.

// Provided response for the compression engine.
// Please provide your response as plain text without any JSON formatting. Your response will be saved directly to: rtl/compression_engine.sv.