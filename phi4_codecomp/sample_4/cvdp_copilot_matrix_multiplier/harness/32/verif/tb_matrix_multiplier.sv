`timescale 1ns/1ps
module tb_matrix_multiplier ();

// Uncomment only one define at a time
// if no define is available, default test will run

// `define MATRIX_MULT_2x2
// `define MATRIX_MULT_3x3
// `define NON_SQUARE_MATRIX_MULT
// `define MATRIX_MULT_1x1

  `ifdef MATRIX_MULT_2x2
    parameter ROW_A = 2;
    parameter COL_A = 2;
    parameter ROW_B = 2;
    parameter COL_B = 2;
  `elsif MATRIX_MULT_3x3
    parameter ROW_A = 3;
    parameter COL_A = 3;
    parameter ROW_B = 3;
    parameter COL_B = 3;
  `elsif NON_SQUARE_MATRIX_MULT
    parameter ROW_A = 2;
    parameter COL_A = 3;
    parameter ROW_B = 3;
    parameter COL_B = 2;
  `elsif MATRIX_MULT_1x1
    parameter ROW_A = 1;
    parameter COL_A = 1;
    parameter ROW_B = 1;
    parameter COL_B = 1;
  `else
    parameter ROW_A = 4;
    parameter COL_A = 4;
    parameter ROW_B = 4;
    parameter COL_B = 4;
  `endif
  parameter INPUT_DATA_WIDTH  = 8                                   ;
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH*2) + $clog2(COL_A);
  parameter NUM_SAMPLES = 10;
  parameter FULL_THROUGHPUT = 1;

  logic                                               clk                  = 0;
  logic                                               srst                    ;
  logic                                               valid_in                ;
  logic [ROW_A-1:0][COL_A-1:0][ INPUT_DATA_WIDTH-1:0] matrix_a                ;
  logic [ROW_B-1:0][COL_B-1:0][ INPUT_DATA_WIDTH-1:0] matrix_b                ;
  logic [ROW_A-1:0][COL_A-1:0][ INPUT_DATA_WIDTH-1:0] matrix_a_q       [$]    ;
  logic [ROW_B-1:0][COL_B-1:0][ INPUT_DATA_WIDTH-1:0] matrix_b_q       [$]    ;
  logic                                               valid_out               ;
  logic [ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH-1:0] matrix_c                ;
  logic [ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH-1:0] matrix_c_q       [$]    ;
  logic [ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH-1:0] matrix_c_expected       ;
  logic                                               give_input           = 0;
  logic                                               give_input_reg       = 0;
  logic                                               matrix_c_matched        ;
  logic [     31:0]                                   valid_in_cnt            ;

  matrix_multiplier #(
    .ROW_A           (ROW_A           ),
    .COL_A           (COL_A           ),
    .ROW_B           (ROW_B           ),
    .COL_B           (COL_B           ),
    .INPUT_DATA_WIDTH(INPUT_DATA_WIDTH)
  ) matrix_multiplier_inst (
    .clk      (clk      ),
    .srst     (srst     ),
    .valid_in (valid_in ),
    .matrix_a (matrix_a ),
    .matrix_b (matrix_b ),
    .valid_out(valid_out),
    .matrix_c (matrix_c ) 
  );

  always
    #1 clk = ~clk;

  initial
  begin
    matrix_c_expected = '0;
    give_input = '0;

    srst = 1'b1;
    repeat(20) @(posedge clk);
    srst = 1'b0;
    repeat(20) @(posedge clk);

    give_input = 1'b1;
    
    `ifdef MATRIX_MULT_2x2
      $display("Matrix Multiplication Test Case: 2x2 Matrix");
    `elsif MATRIX_MULT_3x3
      $display("Matrix Multiplication Test Case: 3x3 Matrix");
    `elsif NON_SQUARE_MATRIX_MULT
      $display("Matrix Multiplication Test Case: Non-Square Matrix (2x3)");
    `elsif MATRIX_MULT_1x1
      $display("Matrix Multiplication Test Case: 1x1 Matrix");
    `else
      $display("Matrix Multiplication Test Case: Default 4x4 Matrix");
    `endif


    wait(valid_in_cnt == NUM_SAMPLES)
    give_input = 1'b0;

    repeat($clog2(COL_A)+2) @(posedge clk);
    #0.1;
    for (int i = 0 ; i < NUM_SAMPLES ; i++) begin
      ref_mat(matrix_a_q.pop_front(),matrix_b_q.pop_front(),matrix_c_expected);
      comp(matrix_c_q.pop_front(), matrix_c_expected, matrix_c_matched);
    end
    #0.1;

    if (matrix_c_matched)
      $display("Test Passed!");
    else
      $display("Test Failed!");

    @(posedge clk);

    $finish;
  end

  always_ff @(posedge clk)
    give_input_reg <= give_input;

  always_ff @(posedge clk)
    if (srst)
      valid_in_cnt <= '0;
    else if (valid_in) begin
      valid_in_cnt <= valid_in_cnt + 1;
    end

  always_ff @(posedge clk)
    if (srst)
      valid_in <= '0;
    else if (give_input_reg && (valid_in_cnt != NUM_SAMPLES))
      valid_in <= FULL_THROUGHPUT ? 1 : $urandom_range(0,1);
    else
      valid_in <= '0;

  always_ff @(posedge clk)
    if (srst)
      matrix_a <= '0;
    else if (give_input_reg)
      matrix_a <= generate_random_matrix_a();

  always_ff @(posedge clk)
    if (srst)
      matrix_b <= '0;
    else if (give_input_reg)
      matrix_b <= generate_random_matrix_b();

  always @(posedge clk)
    if (valid_in)
      matrix_a_q.push_back(matrix_a);

  always @(posedge clk)
    if (valid_in)
      matrix_b_q.push_back(matrix_b);

  always @(posedge clk)
    if (valid_out)
      matrix_c_q.push_back(matrix_c);

  task ref_mat(
    input  logic [ROW_A*COL_A*INPUT_DATA_WIDTH-1:0] mat_a,
    input  logic [ROW_B*COL_B*INPUT_DATA_WIDTH-1:0] mat_b,
    output logic [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] ref_out
  );
    logic [INPUT_DATA_WIDTH-1:0] a_val, b_val;
    logic [OUTPUT_DATA_WIDTH-1:0] partial_sum;

    begin
      for (int i = 0; i < ROW_A; i++) begin
        for (int j = 0; j < COL_B; j++) begin
          partial_sum = 0;
          for (int k = 0; k < COL_A; k++) begin
            a_val = mat_a[((i * COL_A) + k) * INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH];
            b_val = mat_b[((k * COL_B) + j) * INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH];
            partial_sum = partial_sum + (a_val * b_val);
          end
          ref_out[((i * COL_B) + j) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = partial_sum;
        end
      end
    end
  endtask

  task comp(
    input  logic [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] mat_c,
    input  logic [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] mat_check,
    output logic                                     output_match
  );
    begin
      output_match = 1;
      for (int i = 0; i < ROW_A; i++) begin
        for (int j = 0; j < COL_B; j++) begin
          if (mat_c[((i * COL_B) + j) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] !== mat_check[((i * COL_B) + j) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH]) begin
            $display("ERROR: Mismatch at matrix_c[%0d][%0d]. Expected: %0d, Got: %0d",
              i, j, mat_check[((i * COL_B) + j) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH], mat_c[((i * COL_B) + j) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH]);
            output_match = 0;
          end
          else begin
            $display("INFO: Match at matrix_c[%0d][%0d]. Expected: %0d, Got: %0d",
              i, j, mat_check[((i * COL_B) + j) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH], mat_c[((i * COL_B) + j) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH]);
          end
        end
      end
      if (output_match == 1)
        $display("Output matches expected results!");
    end
  endtask

  function automatic logic [(ROW_A * COL_A * INPUT_DATA_WIDTH)-1:0] generate_random_matrix_a();
    logic [(ROW_A * COL_A * INPUT_DATA_WIDTH)-1:0] random_matrix;
    begin
      for (int index = 0; index < ROW_A * COL_A; index++) begin
        random_matrix[index * INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH] = $urandom_range((1 << INPUT_DATA_WIDTH) - 1, 0);
      end
      return random_matrix;
    end
  endfunction


  function automatic logic [(ROW_B * COL_B * INPUT_DATA_WIDTH)-1:0] generate_random_matrix_b();
    logic [(ROW_B * COL_B * INPUT_DATA_WIDTH)-1:0] random_matrix;
    begin
      for (int index = 0; index < ROW_B * COL_B; index++) begin
        random_matrix[index * INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH] = $urandom_range((1 << INPUT_DATA_WIDTH) - 1, 0);
      end
      return random_matrix;
    end
  endfunction

  // -------------------------------------------------------------------------
  // Dump waveforms to a file for analysis
  // Generate a VCD (Value Change Dump) file named "test.vcd" for post-simulation analysis.
  // The dumpvars command tracks all signals in the simulation.
  // -------------------------------------------------------------------------
  initial
    begin
      $dumpfile("test.vcd");
      $dumpvars(0,tb_matrix_multiplier);
    end

endmodule