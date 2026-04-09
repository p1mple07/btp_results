
  // Reduction tree registers
  logic [(ROW_A*COL_B*(MODIFIED_COL_A >> 1)*OUTPUT_DATA_WIDTH)-1:0] red_stage0; // stage 0 output, size = half of MODIFIED_COL_A elements per output element
  // For stage 1 and further, we can define registers generically: red_stage[i] with width = (ROW_A*COL_B*(MODIFIED_COL_A >> (i+1))*OUTPUT_DATA_WIDTH)
