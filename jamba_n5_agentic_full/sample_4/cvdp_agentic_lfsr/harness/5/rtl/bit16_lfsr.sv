always_comb begin
  feedback = lfsr_out[4] ^ lfsr_out[3] ^ lfsr_out[2] ^ lfsr_out[0];
end
