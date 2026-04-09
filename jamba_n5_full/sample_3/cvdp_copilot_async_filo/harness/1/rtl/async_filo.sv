  logic [DATA_WIDTH-1:0] mem[0 : DEPTH-1];
  logic w_ptr, r_ptr;
  logic w_full, r_empty;
  