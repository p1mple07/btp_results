  `define WIDTH 16
  `define RMAX 2
  `define M 1
  `define N 2
  `define REG_WIDTH = WIDTH + $clog2((RMAX * M) ^ N) // compute (RMAX*M) = 2, ^N = 2^2=4, clog2(4)=2, so 16+2=18.
  