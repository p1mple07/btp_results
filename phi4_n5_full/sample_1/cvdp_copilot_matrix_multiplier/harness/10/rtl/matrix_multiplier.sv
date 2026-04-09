
for (gv3 = 0 ; gv3 < COL_A ; gv3++) begin: col_a_gb
          always_ff @(posedge clk)
            if (srst)
              mult_stage[...] <= '0; 
            else
              mult_stage[...] <= matrix_a[...] * matrix_b[...];

          
          always_ff @(posedge clk)
            if (srst)
              add_stage[...] <= '0; 
            else if (gv3 == 0)
              add_stage[...] <= mult_stage[...];
            else
              add_stage[...] <= mult_stage[...] + add_stage[...];
