`timescale 1ns / 1ps

module compression_engine_tb;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in ns (100 MHz)
  parameter LATENCY = 1;     // Number of clock cycles of latency in the RTL

  // Inputs to the Unit Under Test (UUT)
  logic clk;
  logic reset;
  logic [23:0] num_i;

  // Outputs from the UUT
  logic [11:0] mantissa_o;
  logic [3:0] exponent_o;

  // Expected Outputs
  logic [11:0] expected_mantissa [0:LATENCY];
  logic [3:0] expected_exponent [0:LATENCY];

  // Mismatch Indicator
  logic mismatch;

  // Define Number of Tests
  int num_tests = 22;
  int t;

  // Instantiate the compression_engine UUT
  compression_engine uut (
    .clk(clk),
    .reset(reset),
    .num_i(num_i),
    .mantissa_o(mantissa_o),
    .exponent_o(exponent_o)
  );

  // Clock Generation: Toggle every CLK_PERIOD/2 ns
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // Define Test Vectors
  logic [23:0] test_vectors [0:21];

  // Initialize Test Vectors
  initial begin
    test_vectors[0]  = 24'h000000; // All zeros
    test_vectors[1]  = 24'h000001; 
    test_vectors[2]  = 24'h000FFF;
    test_vectors[3]  = 24'h001000;
    test_vectors[4]  = 24'h00F000;
    test_vectors[5]  = 24'h0F0000;
    test_vectors[6]  = 24'h100000;
    test_vectors[7]  = 24'h800000;
    test_vectors[8]  = 24'h400000;
    test_vectors[9]  = 24'h200000;
    test_vectors[10] = 24'h080000;
    test_vectors[11] = 24'h040000;
    test_vectors[12] = 24'h020000;
    test_vectors[13] = 24'h010000;
    test_vectors[14] = 24'h008000;
    test_vectors[15] = 24'h004000; 
    test_vectors[16] = 24'h002000;
    test_vectors[17] = 24'h000800;
    test_vectors[18] = 24'h000400;
    test_vectors[19] = 24'hABCDEF;
    test_vectors[20] = 24'hFFFFF0;
    test_vectors[21] = 24'hFFFFFF; 
  end

  task automatic compute_expected(
    input  logic [23:0] num,
    output logic [3:0]  exp,
    output logic [11:0] mant
  );
    integer i;
    logic [11:0] exp_oh_local;
    logic        onehot_found;
    logic [3:0]  exp_bin_local;
    int          start_bit;

    begin
      exp_oh_local   = 12'b0;
      onehot_found   = 1'b0;
      exp_bin_local  = 4'd0;

      for (i = 23; i >= 12; i = i - 1) begin
        if (num[i] && !onehot_found) begin
          exp_oh_local[i-12] = 1'b1;
          onehot_found = 1'b1;
        end
      end

      for (i = 0; i < 12; i = i + 1) begin
        if (exp_oh_local[i])
          exp_bin_local = i[3:0];
      end

      if (|exp_oh_local)
        exp = exp_bin_local + 4'd1;
      else
        exp = exp_bin_local;

      if (|exp_oh_local) begin
        start_bit = exp + 10; 
        if (start_bit <= 23) 
          mant = num[start_bit -: 12];
        else
          mant = 12'b0; 
      end else begin
        mant = num[11:0];
      end
    end
  endtask

  initial begin
    // Initialize Inputs
    reset = 1;
    num_i = 24'd0;
    mismatch = 1'b0;

    // Initialize Expected Value Pipelines
    for (int i = 0; i <= LATENCY; i++) begin
      expected_mantissa[i] = 12'd0;
      expected_exponent[i] = 4'd0;
    end

    // VCD Dump for Waveform Viewing
    $dumpfile("compression_engine_tb.vcd");
    $dumpvars(0, compression_engine_tb);

    // Apply Reset Sequence
    @(posedge clk);
    reset = 0;

    // Wait One Clock Cycle After Reset
    @(posedge clk);

    // Iterate Over Test Vectors
    for (t = 0; t < num_tests; t = t + 1) begin
      // Apply Test Vector
      num_i = test_vectors[t];

      // Compute Expected Values for Current Input
      compute_expected(num_i, expected_exponent[0], expected_mantissa[0]);

      // Compare Outputs with Delayed Expected Values
      @(posedge clk);
      if ((mantissa_o !== expected_mantissa[LATENCY]) || (exponent_o !== expected_exponent[LATENCY])) begin
        $display("\nMismatch at Test %0d:", t);
        $display("  Input num_i        = %h", test_vectors[t]);
        $display("  Expected exponent  = %d", expected_exponent[LATENCY]);
        $display("  Actual   exponent  = %d", exponent_o);
        $display("  Expected mantissa  = %h", expected_mantissa[LATENCY]);
        $display("  Actual   mantissa  = %h", mantissa_o);
        mismatch = 1;
      end else begin
        $display("Test %0d Passed:", t);
        $display("  Input num_i        = %h", test_vectors[t]);
        $display("  Exponent           = %d", exponent_o);
        $display("  Mantissa           = %h", mantissa_o);
      end

      // Shift Expected Values to Account for Latency
      for (int i = LATENCY; i > 0; i = i - 1) begin
        expected_exponent[i] = expected_exponent[i-1];
        expected_mantissa[i] = expected_mantissa[i-1];
      end
    end

    // Final Result
    if (!mismatch) begin
      $display("\nAll tests passed successfully.");
    end else begin
      $display("\nSome tests failed. Check the mismatches above.");
    end

    $finish;
  end

endmodule