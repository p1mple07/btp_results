
module bit16_lfsr (
    input logic clock,
    input logic reset,
    input logic [15:0] lfsr_seed,
    output logic [15:0] lfsr_out
);

  logic feedback;

  
  always_comb begin
    feedback = lfsr_out[0] ^ lfsr_out[1] ^ lfsr_out[2] ^ lfsr_out[3] ^ lfsr_out[4] ^ lfsr_out[5] ^ lfsr_out[6] ^ lfsr_out[7] ^ lfsr_out[8] ^ lfsr_out[9] ^ lfsr_out[10] ^ lfsr_out[11] ^ lfsr_out[12] ^ lfsr_out[13] ^ lfsr_out[14] ^ lfsr_out[15];
  end

  always_ff @(posedge clock or negedge reset) begin
    if (!reset) lfsr_out <= lfsr_seed; 
    else lfsr_out <= {feedback, lfsr_out[15:1]};  
  end

endmodule
