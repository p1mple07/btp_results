always @* begin
  
    intermediate_stage_1[WIDTH-1] = gray_in[WIDTH-1];
    for (int i = WIDTH - 2; i >= 0; i--) begin
      intermediate_stage_1[i] = intermediate_stage_1[i+1] ^ gray_in[i];
    end
    valid_stage_1 = 1'b1;  

    // Debugging and masking logic
    if (DEBUG_MODE) begin
      masked_output = intermediate_stage_1 ^ {WIDTH{1'b1}};
      debug_mask = ~masked_output;
    end else begin
      masked_output = intermediate_stage_1;
      debug_mask = 1'b0;
    end

    // Final binary output
    final_binary = masked_output;

    // Parity calculation
    parity = ^final_binary;

    // Validity signal
    valid_stage_2 = valid_stage_1;

end
