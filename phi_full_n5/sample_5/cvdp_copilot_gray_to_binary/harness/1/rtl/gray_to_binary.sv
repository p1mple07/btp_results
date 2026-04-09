always @* begin
  
    intermediate_stage_1[WIDTH-1] = gray_in[WIDTH-1];
    for (int i = WIDTH - 2; i >= 0; i--) begin
      intermediate_stage_1[i] = intermediate_stage_1[i+1] ^ gray_in[i];
    end
    valid_stage_1 = 1'b1;  

    if (DEBUG_MODE) begin
      masked_output = ~intermediate_stage_1;
      debug_mask = masked_output;
    end else begin
      masked_output = intermediate_stage_1;
    end

    final_binary = intermediate_stage_1;
    parity = ^final_binary;
    valid_stage_2 = 1'b1;

end
