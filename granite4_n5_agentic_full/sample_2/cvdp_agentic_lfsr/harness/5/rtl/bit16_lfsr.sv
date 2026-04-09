module bit16_lfsr (
    input logic clock,
    input logic reset,
    input logic [15:0] lfsr_seed,
    output logic [15:0] lfsr_out
);

  logic feedback;
  logic [3:0] prev_four_bits;

  
  always_comb begin
    feedback = lfsr_out[4] ^ lfsr_out[3] ^ lfsr_out[2] ^ lfsr_out[0];
  end

  always_ff @(posedge clock or negedge reset) begin
    if (!reset) begin
      lfsr_out <= lfsr_seed; 
      prev_four_bits <= '0;
    end else begin
      lfsr_out <= {feedback, prev_four_bits[15:1]};  
      prev_four_bits <= {prev_four_bits[14:0], feedback};  
    end
  end

endmodule