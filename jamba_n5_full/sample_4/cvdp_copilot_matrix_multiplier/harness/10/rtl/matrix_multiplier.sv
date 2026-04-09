module matrix_multiplier #(
  parameter ROW_A             = 4,
  parameter COL_A             = 4,
  parameter ROW_B             = 4,
  parameter COL_B             = 4,
  parameter INPUT_DATA_WIDTH  = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic                                       clk      ,
  input  logic                                       srst     ,
  input  logic                                       valid_in ,
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a ,
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b ,
  output logic                                       valid_out,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c   // flattened 1D output
);

  // --- 1. Multiplication pipeline (unchanged) --------------------------------
  genvar gv1;
  genvar gv2;
  genvar gv3;

  generate
    logic [COL_A:0] valid_out_reg;
    logic [(ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] mult_stage;
    logic [(ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] add_stage;

    always_ff @(posedge clk)
      if (srst)
        {valid_out, valid_out_reg} <= '0;
      else
        {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};

    for (gv1 = 0; gv1 < ROW_A; gv1++) begin: row_a_gb
      for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_b_gb
        for (gv3 = 0; gv3 < COL_A; gv3++) begin: col_a_gb
          always_ff @(posedge clk)
            if (srst)
              mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:] <= '0;
            else
              mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:] <= matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:];
        end

        always_ff @(posedge clk)
          if (srst)
            add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:] <= '0;
          else if (gv3 == 0)
            add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:];
          else
            add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:] + add_stage[((((gv1*COL_B)+gv2)*COL_A)+(gv3-1))*OUTPUT_DATA_WIDTH+:];
        end
      end
    end
  endgenerate

  // --- 2. Binary accumulation tree (reduced latency) --------------------------------
  always_ff @(posedge clk)
    if (srst)
      {valid_out, valid_out_reg} <= '0;
      mult_stage <= '0;
      add_stage <= '0;
    else
      {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};

      if (mult_stage[0]) begin
        // First clock: initialise the first partial sum
        add_stage[0] <= mult_stage[0];
      end

      // Subsequent clocks: pairwise addition
      for (i = 1; i < MODIFIED_COL_A; i++) begin
        always_ff @(posedge clk)
          if (srst)
            {add_stage[i*2], add_stage[i*2+1]} <= mult_stage[((i-1)*2+0)] + mult_stage[((i-1)*2+1)];
          else
            {add_stage[i*2], add_stage[i*2+1]} <= add_stage[i*2] + add_stage[i*2];
        end
      end

      // Finalise the last remaining partial sum
      always_ff @(posedge clk)
        if (srst)
          {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};
        else
          {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};
          if (valid_out_reg[0])
            matrix_c[0] <= add_stage[0];
        end
  endforeach

  // --- 3. Reset handling -----------------------------------------------------
  always_comb begin
    if (srst) begin
      valid_out <= '0;
      mult_stage <= '0;
      add_stage <= '0;
    end else
    valid_out <= valid_out_reg;
  end

endmodule
