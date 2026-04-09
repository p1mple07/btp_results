module gray_to_binary #(
    parameter WIDTH      = 4,
    parameter DEBUG_MODE = 0
) (
    input  logic [WIDTH-1:0] gray_in,
    output logic [WIDTH-1:0] binary_out,
    output logic [WIDTH-1:0] debug_mask,
    output logic             parity,
    output logic             valid
  )

  logic [WIDTH-1:0] intermediate_stage_1;
  logic [WIDTH-1:0] intermediate_stage_2;
  logic [WIDTH-1:0] masked_output;
  logic [WIDTH-1:0] final_binary;
  logic             valid_stage_1;
  logic             valid_stage_2;

  always @* begin
    intermediate_stage_1[WIDTH-1] = gray_in[WIDTH-1];
    for (int i = WIDTH - 2; i >= 0; i--) begin
      intermediate_stage_1[i] = intermediate_stage_1[i+1] ^ gray_in[i];
    end
    valid_stage_1 = 1'b1;

    // Debugging and masking
    if (DEBUG_MODE == 1) begin
      masked_output = ~binary_out;
      debug_mask = ~binary_out;
    else begin
      masked_output = binary_out;
      debug_mask = (WIDTH == 0) ? 0 : 0;
    end

    // Final outputs
    binary_out = intermediate_stage_1;
    parity = binary_out[0];
    for (int i = 1; i < WIDTH; i++) begin
      parity = parity ^ binary_out[i];
    end
    valid_stage_2 = 1'b1;

  end
endmodule