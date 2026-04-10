module pipeline_mac_tb();

  // ----------------------------------------
  // - Local parameter definitions
  // ----------------------------------------
  localparam DWIDTH = 16;  // Number of bits for input data
  localparam N = 5;        // Number of discrete data points
  localparam CLK_PERIOD = 10;  // Clock period in nanoseconds

  // ----------------------------------------
  // - Internal signal definitions
  // ----------------------------------------
  logic                   clk;         // Clock signal
  logic                   rstn;        // Active-low reset
  logic [DWIDTH-1:0]      multiplicand; // Multiplicand input
  logic [DWIDTH-1:0]      multiplier;   // Multiplier input
  logic                   valid_i;      // Valid input signal
  logic [(DWIDTH << 1)-1:0] result;     // Accumulated result output
  logic                   valid_out;    // Valid output signal
  logic [(DWIDTH << 1)-1:0] expected_result; // Expected result for validation

  integer i;  // Loop variable
  integer seed; // Random seed for testing

  // ----------------------------------------
  // - Top module instantiation
  // ----------------------------------------
  pipeline_mac #(
    .DWIDTH(DWIDTH),
    .N(N)
  ) uut (
    .clk(clk),
    .rstn(rstn),
    .multiplicand(multiplicand),
    .multiplier(multiplier),
    .valid_i(valid_i),
    .result(result),
    .valid_out(valid_out)
  );

  // ----------------------------------------
  // - Clock generation
  // ----------------------------------------
  always #(CLK_PERIOD / 2) clk = ~clk;

  // ----------------------------------------
  // - Stimulus generation
  // ----------------------------------------
  initial begin
    clk = 0;
    rstn = 0;
    multiplicand = 0;
    multiplier = 0;
    valid_i = 0;
    seed = $urandom; // Initialize random seed

    // Apply reset
    #20 rstn = 1;
    #10;

    // Test case 1
    for (i = 0; i < N; i = i + 1) begin
      valid_i = 1;
      multiplicand = i + 1;
      multiplier = (i + 1) * 2;
      expected_result = expected_result + (multiplicand * multiplier);
      #CLK_PERIOD;
    end
    valid_i = 0;
    #CLK_PERIOD;

    // Wait for result
    @(posedge valid_out);
    if (result !== expected_result) begin
      $display("ERROR: Mismatch in expected and actual result! Expected: %0d, Actual: %0d", expected_result, result);
      $stop;
    end else begin
      $display("INFO: Test case 1 passed! Result: %0d", result);
    end

    // Test case 2
    expected_result = 0; // Reset expected result
    for (i = 0; i < N; i = i + 1) begin
      valid_i = 1;
      multiplicand = $urandom(seed) % (1 << DWIDTH);
      multiplier = $urandom(seed) % (1 << DWIDTH);
      expected_result = expected_result + (multiplicand * multiplier);
      #CLK_PERIOD;
    end
    valid_i = 0;
    #CLK_PERIOD;

    // Wait for result
    @(posedge valid_out);
    if (result !== expected_result) begin
      $display("ERROR: Mismatch in expected and actual result! Expected: %0d, Actual: %0d", expected_result, result);
      $stop;
    end else begin
      $display("INFO: Test case 2 passed! Result: %0d", result);
    end

    // Test case 3
    valid_i = 1;
    multiplicand = {DWIDTH{1'b1}};
    multiplier = {DWIDTH{1'b1}};
    expected_result = multiplicand * multiplier;
    for (i = 1; i < N; i = i + 1) begin
      expected_result = expected_result + (multiplicand * multiplier);
      #CLK_PERIOD;
    end
    valid_i = 0;
    #CLK_PERIOD;

    // Wait for result
    @(posedge valid_out);
    if (result !== expected_result) begin
      $display("ERROR: Mismatch in expected and actual result! Expected: %0d, Actual: %0d", expected_result, result);
      $stop;
    end else begin
      $display("INFO: Test case 3 passed! Result: %0d", result);
    end

    // Simulation complete
    $display("All test cases passed!");
    $stop;
  end

  // ----------------------------------------
  // - Monitor outputs
  // ----------------------------------------
  always @(posedge clk) begin
    if (valid_i) begin
      $display("At time %0t: multiplicand = %0d, multiplier = %0d, result = %0d, valid_out = %b",
               $time, multiplicand, multiplier, result, valid_out);
    end
  end

  // ----------------------------------------
  // - Dumping data
  // ----------------------------------------
  initial begin
    $dumpfile("pipeline_mac_tb.vcd");
    $dumpvars(0, pipeline_mac_tb);
  end

endmodule