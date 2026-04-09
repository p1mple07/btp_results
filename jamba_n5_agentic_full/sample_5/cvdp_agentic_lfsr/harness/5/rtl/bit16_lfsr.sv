module bit16_lfsr (
    input logic clock,
    input logic reset,
    input logic [15:0] lfsr_seed,
    output logic [15:0] lfsr_out
);

  logic feedback;

  always_comb begin
    feedback = lfsr_out[0] xor lfsr_out[1] xor lfsr_out[2] xor lfsr_out[3]
              xor lfsr_out[4] xor lfsr_out[5] xor lfsr_out[6] xor lfsr_out[7]
              xor lfsr_out[8] xor lfsr_out[9] xor lfsr_out[10]
              xor lfsr_out[11] xor lfsr_out[12] xor lfsr_out[13]
              xor lfsr_out[14] xor lfsr_out[15];
  end

  always_ff @(posedge clock or negedge reset) begin
    if (!reset) lfsr_out <= lfsr_seed;
    else lfsr_out <= {feedback, lfsr_out[15]};
  end

endmodule
