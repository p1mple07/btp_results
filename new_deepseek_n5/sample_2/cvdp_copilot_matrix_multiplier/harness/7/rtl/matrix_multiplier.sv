module matrix_multiplier #(
  parameter ROW_A             = 4,
  parameter COL_A             = 4,
  parameter ROW_B             = 4,
  parameter COL_B             = 4,
  parameter INPUT_DATA_WIDTH  = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c,
  input  valid_in,
  input  clock,
  input  srst,
  output valid_out
);
  genvar gv1;
  genvar gv2;
  genvar gv3;
  genvar stage;
  genvar m;
  genvar a;
  genvar b;

  // Multiplication stage
  generate
    logic [(COL_A*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_mult;
    for (stage = 0; stage < COL_A; stage++) begin:m
      for (a = 0; a < COL_B; a++) begin:m
        for (b = 0; b < COL_A; b++) begin:m
          if (b == 0)
            assign matrix_mult[((stage*COL_B + a)*COL_A + b)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] = matrix_a[((stage*COL_A + b)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH) & matrix_b[((b*COL_B + a)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH)];
          else
            assign matrix_mult[((stage*COL_B + a)*COL_A + b)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] = matrix_mult[((stage*COL_B + a)*COL_A + b-1)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] & matrix_a[((stage*COL_A + b)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH) & matrix_b[((b*COL_B + a)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH)];
        end
      end
    end

    // Accumulation stage
    generate
      logic [(COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] matrix_acc;
      for (m = 0; m < COL_A; m++) begin:a
        for (stage = 0; stage < COL_A; stage++) begin:a
          for (a = 0; a < COL_B; a++) begin:a
            if (stage == 0)
              assign matrix_acc[((stage*COL_B + a)*COL_A + m)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_mult[((stage*COL_B + a)*COL_A + m)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
            else
              assign matrix_acc[((stage*COL_B + a)*COL_A + m)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_acc[((stage*COL_B + a)*COL_A + m)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] & matrix_mult[((stage*COL_B + a)*COL_A + m)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
          end
        end
      end
  endgenerate

  // Output stage
  generate
    logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c;
    for (stage = 0; stage < COL_A; stage++) begin:o
      for (m = 0; m < COL_B; m++) begin:o
        assign matrix_c[((stage*COL_B + m)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_acc[((stage*COL_B + m)*COL_A + (COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
      end
    end

    // Valid signal propagation
    logic valid_shift;
    valid_shift = valid_in;
    always positive_edge valid_shift: valid_shift = valid_in;

    assign valid_out = valid_shift after COL_A + 2 cycles;
  endgenerate

  // Reset handling
  always positive_edge clock: 
    if (srst) begin
      matrix_mult, matrix_acc, matrix_c, valid_shift, valid_out = 0;
    endif
  end
endmodule