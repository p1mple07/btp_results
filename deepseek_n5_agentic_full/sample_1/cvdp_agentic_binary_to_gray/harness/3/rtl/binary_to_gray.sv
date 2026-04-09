parameter WIDTH = 6;
input     [WIDTH-1:0] binary_in;
output    [WIDTH-1:0] gray_out;

always_comb
  gray_out = binary_in ^ (binary_in >> 1);