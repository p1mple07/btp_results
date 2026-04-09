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

  // Combinational always block for conversion and debugging
  always @* begin
  
    // Stage 1: Intermediate Binary Computation
    intermediate_stage_1[WIDTH-1] = gray_in[WIDTH-1];
    for (int i = WIDTH - 2; i >= 0; i--) begin
      intermediate_stage_1[i] = intermediate_stage_1[i+1] ^ gray_in[i];
    end
    valid_stage_1 = 1'b1;  
  
    // Stage 2: Debugging and Masking
    if (DEBUG_MODE) begin
      // When debugging is enabled, invert the intermediate binary to produce debug mask
      masked_output = ~intermediate_stage_1;
      debug_mask = masked_output;
    end else begin
      // When debugging is disabled, pass the computed binary directly and set debug mask to zero
      masked_output = intermediate_stage_1;
      debug_mask = {WIDTH{1'b0}};
    end
    valid_stage_2 = 1'b1;  
  
    // Stage 3: Final Outputs
    final_binary = masked_output;
    binary_out = final_binary;
    // Compute parity: reduction XOR to determine if even (0) or odd (1)
    parity = ^final_binary;
    valid = valid_stage_1 && valid_stage_2; // Both stages valid
  
  end

endmodule