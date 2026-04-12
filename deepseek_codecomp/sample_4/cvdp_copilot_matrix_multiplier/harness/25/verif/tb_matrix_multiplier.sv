`timescale 1ns/1ps
module tb_matrix_multiplier ();

// Uncomment only one define at a time
// if no define is available, default test will run

// `define BASIC_MATRIX_MUL_2x2
// `define ZERO_MATRIX_MUL_2x2
// `define IDENTITY_MATRIX_MUL_3x3
// `define NON_SQUARE_MATRIX_MUL
// `define MAX_VALUE_TESTCASE_2x2 // To check Overflow Handling
// `define SINGLE_ELEMENT_MATRIX_MUL_1x1

  // -------------------------------------------------------------------------
  // Parameter Declarations
  // ROW_A             - Number of rows in matrix A
  // COL_A             - Number of columns in matrix A
  // ROW_B             - Number of rows in matrix B
  // COL_B             - Number of columns in matrix B
  // INPUT_DATA_WIDTH  - Bit width of each element in input matrices A and B
  // OUTPUT_DATA_WIDTH - Bit width of the output matrix element
  // -------------------------------------------------------------------------
  `ifdef BASIC_MATRIX_MUL_2x2
    parameter ROW_A = 2;
    parameter COL_A = 2;
    parameter ROW_B = 2;
    parameter COL_B = 2;
  `elsif ZERO_MATRIX_MUL_2x2
    parameter ROW_A = 2;
    parameter COL_A = 2;
    parameter ROW_B = 2;
    parameter COL_B = 2;
  `elsif IDENTITY_MATRIX_MUL_3x3
    parameter ROW_A = 3;
    parameter COL_A = 3;
    parameter ROW_B = 3;
    parameter COL_B = 3;
  `elsif NON_SQUARE_MATRIX_MUL
    parameter ROW_A = 2;
    parameter COL_A = 3;
    parameter ROW_B = 3;
    parameter COL_B = 2;
  `elsif MAX_VALUE_TESTCASE_2x2
    parameter ROW_A = 2;
    parameter COL_A = 2;
    parameter ROW_B = 2;
    parameter COL_B = 2;
  `elsif SINGLE_ELEMENT_MATRIX_MUL_1x1
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

  // Signal Declarations
  logic                                                       clk               = 0; // Clock signal
  logic                                                       srst                 ; // Reset signal (active high, Synchronous)
  logic                                                       valid_in             ; // Input valid signal
  logic [        ROW_A-1:0][COL_A-1:0][ INPUT_DATA_WIDTH-1:0] matrix_a             ; // Input matrix A
  logic [        ROW_B-1:0][COL_B-1:0][ INPUT_DATA_WIDTH-1:0] matrix_b             ; // Input matrix B
  logic                                                       valid_out            ; // Output valid signal
  logic [        ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH-1:0] matrix_c             ; // Output matrix C
  logic [        ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH-1:0] matrix_c_expected    ;
  logic                                                       give_input        = 0;
  logic                                                       give_input_reg    = 0;
  logic [$clog2(COL_A+2):0]                                   latency_cnt          ;
  logic [$clog2(COL_A+2):0]                                   latency_cnt_comb     ;
  logic                                                       matrix_c_matched     ;
  logic                                                       latency_match        ;

  // Instantiate the matrix multiplier module
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
    .matrix_a (matrix_a ), // Matrix A input
    .matrix_b (matrix_b ), // Matrix B input
    .valid_out(valid_out),
    .matrix_c (matrix_c )  // Output matrix C
  );

  // Clock generation: Toggle clock every 1ns (Clock Period = 2ns)
  always
    #1 clk = ~clk;

  // Initial block to define testbench stimulus
  initial
  begin
    // ---------------------------------------------------------------------
    // Step 1: Initialize the signals
    // ---------------------------------------------------------------------
    matrix_c_expected = '0;
    give_input = '0;

    // ---------------------------------------------------------------------
    // Step 2: Apply reset
    // Keep the reset signal high for 20 clock cycles, then release it.
    // ---------------------------------------------------------------------
    srst = 1'b1;
    repeat(20) @(posedge clk);
    srst = 1'b0;
    repeat(20) @(posedge clk);

    give_input = 1'b1; // Start input signal

    `ifdef BASIC_MATRIX_MUL_2x2
      // ---------------------------------------------------------------------
      // Test Case: Basic 2x2 Matrix Multiplication
      // ---------------------------------------------------------------------
      $display("Perfrom Basic Matrix Multiplication 2x2");

    `elsif ZERO_MATRIX_MUL_2x2
      // ---------------------------------------------------------------------
      // Test Case: Zero Matrix Multiplication
      // ---------------------------------------------------------------------
      $display("Perfrom Zero Matrix Multiplication");

    `elsif IDENTITY_MATRIX_MUL_3x3
      // ---------------------------------------------------------------------
      // Test Case: Identity Matrix Multiplication
      // ---------------------------------------------------------------------
      $display("Perfrom Identity Matrix Multiplication");

    `elsif NON_SQUARE_MATRIX_MUL
      // ---------------------------------------------------------------------
      // Test Case: Non-Square Matrix Multiplication
      // ---------------------------------------------------------------------
      $display("Perfrom Non-Square Matrix Multiplication");

    `elsif MAX_VALUE_TESTCASE_2x2
      // ---------------------------------------------------------------------
      // Test Case: Max Value Matrix Multiplication (Overflow Test)
      // ---------------------------------------------------------------------
      $display("Perfrom Max Value Matrix Multiplication");

    `elsif SINGLE_ELEMENT_MATRIX_MUL_1x1

      // ---------------------------------------------------------------------
      // Test Case: Single Element Matrix Multiplication 1x1
      // ---------------------------------------------------------------------
      $display("Perfrom Single Element Matrix Multiplication 1x1");
    `else

      // ---------------------------------------------------------------------
      // Test Case: Basic Matrix Multiplication 4x4
      // ---------------------------------------------------------------------
      $display("Perfrom Matrix Multiplication 4x4");
    `endif


    // Wait for one clock cycle and disable give_input
    @(posedge clk);
    give_input = 1'b0;

    #0.1;
    ref_mat(matrix_a,matrix_b,matrix_c_expected);

    // Wait until the valid_out signal indicates that the result is ready
    wait(valid_out);

    $display("Valid output asserted. Comparing results...");

    #0.1;
    comp(matrix_c,matrix_c_expected,matrix_c_matched);

    if (latency_match && matrix_c_matched)
      $display("Test Passed!");
    else
      $display("Test Failed!");

    // Wait for one more clock cycle before terminating the simulation
    @(posedge clk);

    $finish;
  end

  always_ff @(posedge clk)
    give_input_reg <= give_input;

  always_ff @(posedge clk)
    if (srst)
      valid_in <= '0;
    else if (give_input && !give_input_reg)
      valid_in <= 1'b1;
    else
      valid_in <= '0;

  always_ff @(posedge clk)
    if (srst)
      matrix_a <= '0;
    else if (give_input)
    begin
      `ifdef BASIC_MATRIX_MUL_2x2
        {matrix_a[0][0],matrix_a[0][1]} <= {8'd1 ,8'd2}; // Row 1 of Matrix A
        {matrix_a[1][0],matrix_a[1][1]} <= {8'd3 ,8'd4}; // Row 2 of Matrix A

      `elsif ZERO_MATRIX_MUL_2x2
        {matrix_a[0][0],matrix_a[0][1]} <= {8'd1 ,8'd2}; // Row 1 of Matrix A
        {matrix_a[1][0],matrix_a[1][1]} <= {8'd3 ,8'd4}; // Row 2 of Matrix A

      `elsif IDENTITY_MATRIX_MUL_3x3
        {matrix_a[0][0],matrix_a[0][1],matrix_a[0][2]} <= {8'd3  ,8'd5  ,8'd7}; // Row 1 of Matrix A
        {matrix_a[1][0],matrix_a[1][1],matrix_a[1][2]} <= {8'd2  ,8'd6  ,8'd8}; // Row 2 of Matrix A
        {matrix_a[2][0],matrix_a[2][1],matrix_a[2][2]} <= {8'd9  ,8'd1  ,8'd4}; // Row 3 of Matrix A

      `elsif NON_SQUARE_MATRIX_MUL
        {matrix_a[0][0],matrix_a[0][1],matrix_a[0][2]} <= {8'd2  ,8'd4  ,8'd6}; // Row 1 of Matrix A
        {matrix_a[1][0],matrix_a[1][1],matrix_a[1][2]} <= {8'd1  ,8'd3  ,8'd5}; // Row 2 of Matrix A


      `elsif MAX_VALUE_TESTCASE_2x2
        {matrix_a[0][0],matrix_a[0][1]} <= {8'd255  ,8'd255}; // Row 1 of Matrix A
        {matrix_a[1][0],matrix_a[1][1]} <= {8'd255  ,8'd255}; // Row 2 of Matrix A

      `elsif SINGLE_ELEMENT_MATRIX_MUL_1x1
        matrix_a[0][0] <= {8'd5};  // Row 1 of Matrix A

      `else
        {matrix_a[0][0],matrix_a[0][1],matrix_a[0][2],matrix_a[0][3]} <= {8'd1  ,8'd2  ,8'd3  ,8'd4 }; // Row 1 of Matrix A
        {matrix_a[1][0],matrix_a[1][1],matrix_a[1][2],matrix_a[1][3]} <= {8'd5  ,8'd6  ,8'd7  ,8'd8 }; // Row 2 of Matrix A
        {matrix_a[2][0],matrix_a[2][1],matrix_a[2][2],matrix_a[2][3]} <= {8'd9  ,8'd10 ,8'd11 ,8'd12}; // Row 3 of Matrix A
        {matrix_a[3][0],matrix_a[3][1],matrix_a[3][2],matrix_a[3][3]} <= {8'd13 ,8'd14 ,8'd15 ,8'd0 }; // Row 4 of Matrix A
      `endif
    end

  always_ff @(posedge clk)
    if (srst)
      matrix_b <= '0;
    else if (give_input)
    begin
      `ifdef BASIC_MATRIX_MUL_2x2
        {matrix_b[0][0],matrix_b[0][1]} = {8'd5 ,8'd6}; // Row 1 of Matrix B
        {matrix_b[1][0],matrix_b[1][1]} = {8'd7 ,8'd8}; // Row 2 of Matrix B

      `elsif ZERO_MATRIX_MUL_2x2
        {matrix_b[0][0],matrix_b[0][1]} = {8'd0 ,8'd0}; // Row 1 of Matrix B
        {matrix_b[1][0],matrix_b[1][1]} = {8'd0 ,8'd0}; // Row 2 of Matrix B

      `elsif IDENTITY_MATRIX_MUL_3x3
        {matrix_b[0][0],matrix_b[0][1],matrix_b[0][2]} = {8'd1  ,8'd0  ,8'd0}; // Row 1 of Matrix B
        {matrix_b[1][0],matrix_b[1][1],matrix_b[1][2]} = {8'd0  ,8'd1  ,8'd0}; // Row 2 of Matrix B
        {matrix_b[2][0],matrix_b[2][1],matrix_b[2][2]} = {8'd0  ,8'd0  ,8'd1}; // Row 3 of Matrix B

      `elsif NON_SQUARE_MATRIX_MUL
        {matrix_b[0][0],matrix_b[0][1]} = {8'd7  ,8'd8 }; // Row 1 of Matrix B
        {matrix_b[1][0],matrix_b[1][1]} = {8'd9  ,8'd10}; // Row 2 of Matrix B
        {matrix_b[2][0],matrix_b[2][1]} = {8'd11 ,8'd12}; // Row 3 of Matrix B

      `elsif MAX_VALUE_TESTCASE_2x2
        {matrix_b[0][0],matrix_b[0][1]} = {8'd255  ,8'd255}; // Row 1 of Matrix B
        {matrix_b[1][0],matrix_b[1][1]} = {8'd255  ,8'd255}; // Row 2 of Matrix B

      `elsif SINGLE_ELEMENT_MATRIX_MUL_1x1
        matrix_b[0][0] = {8'd10}; // Row 1 of Matrix B

      `else
        {matrix_b[0][0],matrix_b[0][1],matrix_b[0][2],matrix_b[0][3]} = {8'd1  ,8'd1  ,8'd1  ,8'd1}; // Row 1 of Matrix B
        {matrix_b[1][0],matrix_b[1][1],matrix_b[1][2],matrix_b[1][3]} = {8'd2  ,8'd2  ,8'd2  ,8'd2}; // Row 2 of Matrix B
        {matrix_b[2][0],matrix_b[2][1],matrix_b[2][2],matrix_b[2][3]} = {8'd3  ,8'd3  ,8'd3  ,8'd3}; // Row 3 of Matrix B
        {matrix_b[3][0],matrix_b[3][1],matrix_b[3][2],matrix_b[3][3]} = {8'd4  ,8'd4  ,8'd4  ,8'd4}; // Row 4 of Matrix B
      `endif
    end

  always_ff @(posedge clk)
    if (srst)
      latency_cnt <= '0;
    else
      latency_cnt <= latency_cnt_comb;

  always_comb
  begin
    latency_cnt_comb = latency_cnt;
    latency_match = 1;
    if (valid_out)
    begin
      if (latency_cnt_comb != ($clog2(COL_A)+2))
      begin
        latency_match = 0;
        $display("ERROR: Mismatch Latency. Expected: %0d, Got: %0d",($clog2(COL_A)+2),latency_cnt_comb);
      end
      else
      begin
        $display("INFO: Match Latency. Expected: %0d, Got: %0d",($clog2(COL_A)+2),latency_cnt_comb);
      end
    end

    if (valid_out)
      latency_cnt_comb = '0;
    else if (valid_in)
      latency_cnt_comb = 'd1;
    else if (latency_cnt_comb != '0)
      latency_cnt_comb = latency_cnt_comb + 'd1;
  end


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
    output logic                                    output_match
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