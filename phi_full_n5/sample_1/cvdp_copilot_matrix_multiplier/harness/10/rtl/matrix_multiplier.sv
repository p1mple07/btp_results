   module matrix_multiplier #(
     parameter ROW_A             = 4,
     parameter COL_A             = 4,
     parameter ROW_B             = 4,
     parameter COL_B             = COL_A,
     parameter INPUT_DATA_WIDTH  = 8,
     parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
   ) (
     input  logic                 clk,
     input  logic                 srst,
     input  logic                 valid_in,
     input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
     input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
     output logic                 valid_out,
     output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
   );

   localparam MODIFIED_COL_A = $clog2(COL_A) + 1;
   localparam HALF_MODIFIED_COL_A = (MODIFIED_COL_A - 1) / 2;

   generate
     logic [COL_A:0] valid_out_reg;
     logic [(ROW_A*COL_B*MODIFIED_COL_A)*OUTPUT_DATA_WIDTH-1:0] mult_stage;
     logic [(ROW_A*COL_B*HALF_MODIFIED_COL_A)*OUTPUT_DATA_WIDTH-1:0] add_stage;

     always_ff @(posedge clk) begin
       if (srst) begin
         valid_out <= '0;
         valid_out_reg <= '0;
         mult_stage <= {{(COL_A == 1) ? {'(COL_A*INPUT_DATA_WIDTH)-1{1'b0}:'(COL_A*INPUT_DATA_WIDTH)-1{1'b0}}};
         add_stage <= {{(COL_B == 1) ? {'(COL_B*INPUT_DATA_WIDTH)-1{1'b0}:'(COL_B*INPUT_DATA_WIDTH)-1{1'b0}}};
       end else begin
         mult_stage <= {{(COL_A == 1) ? {'(COL_A*INPUT_DATA_WIDTH)-1{1'b0}:'(COL_A*INPUT_DATA_WIDTH)-1{1'b0}}};
       end
     end

     for (genvar gv1 = 0; gv1 < ROW_A; gv1++) begin : row_a_gb
       for (genvar gv2 = 0; gv2 < COL_B; gv2++) begin : col_b_gb
         for (genvar gv3 = 0; gv3 < HALF_MODIFIED_COL_A; gv3++) begin : col_a_gb
           integer offset = ((gv1*COL_B)+gv2)*MODIFIED_COL_A+gv3;
           if (gv3 == 0) begin
             mult_stage[offset+(COL_A*OUTPUT_DATA_WIDTH-1):offset+OUTPUT_DATA_WIDTH-1] <= mult_stage[offset:offset+OUTPUT_DATA_WIDTH-1] + mult_stage[offset+(COL_A*OUTPUT_DATA_WIDTH-1):offset];
           end else begin
             mult_stage[offset+(COL_A*OUTPUT_DATA_WIDTH-1):offset+OUTPUT_DATA_WIDTH-1] <= mult_stage[offset:offset];
           end
         end
       end

       always_ff @(posedge clk) begin
         if (srst) begin
           add_stage <= {{(COL_B == 1) ? {'(COL_B*INPUT_DATA_WIDTH)-1{1'b0}:'(COL_B*INPUT_DATA_WIDTH)-1{1'b0}}};
         else if (gv3 == HALF_MODIFIED_COL_A - 1) begin
           add_stage <= add_stage + mult_stage[(gv1*COL_B)+gv2*(MODIFIED_COL_A)-1:((gv1*COL_B)+gv2*(MODIFIED_COL_A)-1)*OUTPUT_DATA_WIDTH-1];
         end else begin
           add_stage <= add_stage + add_stage[(gv1*COL_B)+gv2*(MODIFIED_COL_A)-1:((gv1*COL_B)+gv2*(MODIFIED_COL_A)-1)*OUTPUT_DATA_WIDTH-1];
         end
       end

       if (srst) begin
         matrix_c[(gv1*COL_B)+gv2*OUTPUT_DATA_WIDTH-1:gv2*OUTPUT_DATA_WIDTH-1] <= '0;
       end else if (valid_out_reg[COL_A]) begin
         matrix_c[(gv1*COL_B)+gv2*OUTPUT_DATA_WIDTH-1:gv2*OUTPUT_DATA_WIDTH-1] <= add_stage[COL_A*(OUTPUT_DATA_WIDTH-1):COL_A];
       end
     end
   endgenerate
   