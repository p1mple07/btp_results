module bit16_lfsr (
    input logic clock,
    input logic reset,
    input logic [15:0] lfsr_seed,
    output logic [15:0] lfsr_out
);

  reg feedback;

  always_ff @(posedge clock or negedge reset) begin
    if (!reset) begin
      lfsr_out <= lfsr_seed;
    end else begin
      feedback = lfsr_out[4] ^ lfsr_out[3] ^ lfsr_out[2] ^ lfsr_out[0];
      lfsr_out <= {feedback, lfsr_out[15:1]};
    end
  end

endmodule
