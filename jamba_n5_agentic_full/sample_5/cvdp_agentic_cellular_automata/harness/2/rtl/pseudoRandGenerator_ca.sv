module pseudoRandGenerator_ca (
    input wire clock,
    input wire reset,
    input wire [15:0] CA_seed,
    input wire [1:0] rule_sel,
    output reg [15:0] CA_out
);

reg [15:0] next_state;

always_comb begin
  for (int i = 0; i < 16; i++) begin
    int left = CA_out[(i-1) % 16];
    int center = CA_out[i];
    int right = CA_out[(i+1) % 16];

    if (rule_sel == 2'b00) begin
      if (left == 1 && center == 1 && right == 1)
        next_state[i] = 0;
      else if (left == 1 && center == 1 && right == 0)
        next_state[i] = 0;
      else if (left == 1 && center == 0 && right == 1)
        next_state[i] = 0;
      else if (left == 1 && center == 0 && right == 0)
        next_state[i] = 1;
      else if (left == 0 && center == 1 && right == 1)
        next_state[i] = 1;
      else if (left == 0 && center == 1 && right == 0)
        next_state[i] = 1;
      else if (left == 0 && center == 0 && right == 1)
        next_state[i] = 1;
      else if (left == 0 && center == 0 && right == 0)
        next_state[i] = 0;
    } else if (rule_sel == 2'b01) begin
      if (left == 1 && center == 1 && right == 1)
        next_state[i] = 0;
      else if (left == 1 && center == 1 && right == 0)
        next_state[i] = 1;
      else if (left == 1 && center == 0 && right == 1)
        next_state[i] = 1;
      else if (left == 1 && center == 0 && right == 0)
        next_state[i] = 0;
      else if (left == 0 && center == 1 && right == 1)
        next_state[i] = 1;
      else if (left == 0 && center == 1 && right == 0)
        next_state[i] = 1;
      else if (left == 0 && center == 0 && right == 1)
        next_state[i] = 1;
      else if (left == 0 && center == 0 && right == 0)
        next_state[i] = 0;
    } else {
      next_state[i] = 0;
    }
  end
end

always_ff @(posedge clock) begin
  if (reset) begin
    CA_out <= {16'b0};
  end else begin
    CA_out <= next_state;
  end
end

endmodule
