module reverse_bits(
  input [31:0] num_in,
  output logic [31:0] num_out
);

  always_comb begin : p_reverse_bits
    num_out = 0;
    for (int i=0; i<32; i++) begin
      num_out[i] = num_in[31 - i];
    end
  end

endmodule