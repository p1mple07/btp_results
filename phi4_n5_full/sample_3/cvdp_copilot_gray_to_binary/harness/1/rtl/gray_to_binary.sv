module gray_to_binary #(
    parameter WIDTH      = 4,  // Specify the width of the Gray code input
    parameter DEBUG_MODE = 0   // Debug mode: 0 = Disabled, 1 = Enabled
) (
    input  logic [WIDTH-1:0] gray_in,     
    output logic [WIDTH-1:0] binary_out, 
    output logic [WIDTH-1:0] debug_mask,  
    output logic             parity,   
    output logic             valid        
);

  // Internal signals for processing stages
  logic [WIDTH-1:0] intermediate_stage_1; 
  logic [WIDTH-1:0] intermediate_stage_2;  
  logic [WIDTH-1:0] masked_output;
  logic [WIDTH-1:0] final_binary;  
  logic             valid_stage_1;  
  logic             valid_stage_2;  

  always @* begin
    // Stage 1: Intermediate Binary Computation
    intermediate_stage_1[WIDTH-1] = gray_in[WIDTH-1];
    for (int i = WIDTH - 2; i >= 0; i--) begin
      intermediate_stage_1[i] = intermediate_stage_1[i+1] ^ gray_in[i];
    end
    valid_stage_1 = 1'b1;

    // Stage 2: Debugging and Masking
    if (DEBUG_MODE == 1) begin
      masked_output = ~intermediate_stage_1;  // Invert for diagnostic purposes
      debug_mask    = masked_output;
      valid_stage_2 = 1'b1;
    end else begin
      debug_mask    = '0;
      valid_stage_2 = 1'b1;
    end

    // Stage 3: Final Outputs
    final_binary = intermediate_stage_1;  // Final binary output remains as computed
    binary_out   = final_binary;
    parity       = ^final_binary;          // XOR reduction to compute parity (0 = even, 1 = odd)
    valid        = 1'b1;
  end

endmodule