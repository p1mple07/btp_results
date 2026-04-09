module gray_to_binary #(
    parameter WIDTH      = 4,  // Specify the width of the Gray code input
    parameter DEBUG_MODE = 0   // Debug mode: 0 = Disabled, 1 = Enabled
) (
    input  logic [WIDTH-1:0] gray_in,     
    output logic [WIDTH-1:0] binary_out, 
    output logic [WIDTH-1:0] debug_mask,  
    output logic             parity,   
    output logic             valid       

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

    if (DEBUG_MODE == 1) begin
      masked_output = ^intermediate_stage_1;
      debug_mask = masked_output;
    end else begin
      masked_output = intermediate_stage_1;
      debug_mask = 1'b0;
    end

    final_binary = masked_output;
    parity = ^final_binary;
    valid_stage_2 = 1'b1;

  end

endmodule
