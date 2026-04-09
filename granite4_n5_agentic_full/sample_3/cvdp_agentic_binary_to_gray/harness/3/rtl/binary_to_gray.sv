module binary_to_gray #(
  parameter int Width = 8
)(
  input logic [Width-1:0] binary_in,
  output logic [Width-1:0] gray_out
);

  always_comb begin : p_next_state
    gray_out = binary_in;
    gray_out[Width-1] = binary_in[Width-1];
    for (int i=Width-2; i>=0; i--) begin : gen_gray_code
      gray_out[i] = binary_in[i] ^ binary_in[i+1];
    end
  end

endmodule