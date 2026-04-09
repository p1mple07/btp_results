
integer i;
logic [17:0] a_reg, c_reg;
begin
   a_reg = a;
   c_reg = c;
   for(i = 0; i < 18; i = i+1) begin
      if(c_reg[17:9] == 18'b0) begin
         b = a_reg;
         d = c_reg;
         break;
      end else begin
         a_reg = a_reg >> 1;
         c_reg = c_reg >> 1;
      end
   end
end
