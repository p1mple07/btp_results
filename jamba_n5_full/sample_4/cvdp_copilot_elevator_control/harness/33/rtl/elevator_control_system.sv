
reg [19:0] shift;

integer i;

always @(num)
begin
    shift[19:8] = 0;
    shift[7:0] = num;
