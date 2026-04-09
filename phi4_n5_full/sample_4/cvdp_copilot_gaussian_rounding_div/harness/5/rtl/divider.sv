
integer i;
logic [17:0] temp;
begin
  temp = a;
  shift = 0;
  for (i=0; i<9; i=i+1) begin
     if (temp < 512) begin
         b = temp;
         d = c >> shift;
         break;
     end else begin
         temp = temp >> 1;
         shift = shift + 1;
     end
  end
end
