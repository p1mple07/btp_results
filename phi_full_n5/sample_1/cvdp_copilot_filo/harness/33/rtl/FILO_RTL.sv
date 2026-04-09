always @(posedge clk or posedge reset) begin
  if (reset) begin
    top <= 0;
    empty <= 1;
    full <= 0;
    feedthrough_valid <= 0;
    data_out <= 0;  
  end else begin
    
    if (push && !full) begin
      memory[top] <= data_in;  
      top <= top + 1;  
      feedthrough_valid <= 0;
    end

    if (pop && !empty) begin
      if (feedthrough_valid) begin
        data_out <= memory[top-1];  // Corrected to access memory at top-1
        feedthrough_valid <= 0;
      end else begin
        top <= top;  // No need to change top, as it will automatically decrement
      end
    end

    empty <= (top == 0);
    full  <= (top == FILO_DEPTH);  
  end
end
