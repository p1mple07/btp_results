
   for (int i = 0; i < 16; i++) begin
       carry[i] = G3[i - 1] | (P3[i - 1] & carry[i - 1]); // Correct carry propagation
   end
   