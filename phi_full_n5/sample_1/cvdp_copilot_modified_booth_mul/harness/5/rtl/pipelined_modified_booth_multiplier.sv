// ...

// State 3: Partial Summation
if (valid_reg[1]) begin 
    s1 = {partial_products[0], partial_products[1], 'h0};
    s2 = {partial_products[3], partial_products[4], 'h0};
    
    valid_reg[2] <= 1; // State 3 done, mark State 4 as ready
    valid_reg[1] <= 0; // Clear state 2 active flag
end 
else
  valid_reg[2] <= 0; // State 3 done, mark State 4 as ready 

// State 4: Sum of Sums
if (valid_reg[2]) begin 
    s3 = s1 + s2;
    s4 = {partial_products[6], partial_products[7], 'h0};
    
    valid_reg[3] <= 1; // State 4 done, mark State 5 as ready
    valid_reg[2] <= 0; // Clear state 3 active flag
end 
else
  valid_reg[3] <= 0; // State 4 done, mark State 5 as ready

// State 5: Final Result
if (valid_reg[3]) begin
    result = s3 + s4;
    done <= 1;  // Output done signal
    valid_reg[3] <= 0; // Reset state 5 active flag after result computation
end 
else
begin
  result <= 0;
  done <= 1'b0; 
end 

// ...
