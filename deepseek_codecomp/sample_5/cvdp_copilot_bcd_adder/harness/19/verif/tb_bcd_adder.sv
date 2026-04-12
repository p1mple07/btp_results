module tb_multi_digit_bcd_add_sub();

  // Parameters
  parameter N = 4;  // Number of BCD digits

  // Inputs
  reg [4*N-1:0] A;        // N-digit BCD input A
  reg [4*N-1:0] B;        // N-digit BCD input B
  reg           add_sub;  // 1 for addition, 0 for subtraction

  // Outputs
  wire [4*N-1:0] result;       // N-digit result
  wire           carry_borrow; // Carry-out or borrow-out

  integer i;             

  // Declare max_value as a module-level variable
  integer max_value;

  // Instantiate the multi-digit BCD adder-subtractor
  multi_digit_bcd_add_sub #(.N(N)) uut (
      .A(A),
      .B(B),
      .add_sub(add_sub),
      .result(result),
      .carry_borrow(carry_borrow)
  );

  initial begin
    input_data();        
    #10;                 
    $finish;             
  end

  // Function to convert integer to BCD
  function [4*N-1:0] int_to_bcd(input integer value);
    integer idx;
    reg [3:0] digits [N-1:0];
    reg [4*N-1:0] bcd_result;
    begin
      bcd_result = 0; 
      for (idx = 0; idx < N; idx = idx + 1) begin
        digits[idx] = value % 10; 
        value = value / 10;     
      end
      for (idx = 0; idx < N; idx = idx + 1) begin
        bcd_result = bcd_result | (digits[idx] << (4 * idx)); 
      end
      int_to_bcd = bcd_result;
    end
  endfunction

  // Function to convert BCD to string for display
  function [8*N-1:0] bcd_to_str(input [4*N-1:0] bcd);
    integer idx;
    reg [3:0] digit;
    reg [8*N-1:0] str;
    begin
      str = "";
      for (idx = N-1; idx >= 0; idx = idx - 1) begin
        digit = bcd[4*idx +: 4]; 
        str = {str, digit + 8'h30}; 
      end
      bcd_to_str = str;
    end
  endfunction

  // Task to execute a test case
  task test_case(input integer test_num, input integer A_int, input integer B_int, input reg add_sub_op, input string goal);
    integer computed_result_int;
    integer expected_carry_out;
    reg [4*N-1:0] expected_result_bcd;
    begin
      $display("Test Case %0d: %s", test_num, goal);
      A = int_to_bcd(A_int);
      B = int_to_bcd(B_int);
      add_sub = add_sub_op;
      #10;

      if (add_sub) begin
        // Addition
        computed_result_int = A_int + B_int;
        expected_carry_out = (computed_result_int >= max_value) ? 1 : 0;
      end else begin
        // Subtraction
        computed_result_int = A_int - B_int;
        if (computed_result_int < 0) begin
          computed_result_int = computed_result_int + max_value; 
          expected_carry_out = 0; 
        end else begin
          expected_carry_out = 1; 
        end
      end
      expected_result_bcd = int_to_bcd(computed_result_int % max_value);

      $display("Inputs: A=%s, B=%s, Operation=%s", bcd_to_str(A), bcd_to_str(B), (add_sub ? "Addition" : "Subtraction"));
      $display("Output: Result=%s, Expected Result=%s, Carry=%b", bcd_to_str(result), bcd_to_str(expected_result_bcd), carry_borrow);
      if (result !== expected_result_bcd) begin
        $display("Error: Expected result=%s, but got result=%s", bcd_to_str(expected_result_bcd), bcd_to_str(result));
      end
      if (carry_borrow !== expected_carry_out) begin
        $display("Error: Expected carry_borrow=%b, but got carry_borrow=%b", expected_carry_out, carry_borrow);
      end
    end
  endtask

  // Task to generate input data and verify outputs
  task input_data();
    integer A_int, B_int;
    begin
      max_value = 1;
      for (i = 0; i < N; i = i + 1)
        max_value = max_value * 10; 


      test_case(1, 0, $urandom_range(1, max_value - 1), 0, "Validate subtraction when A = 0 and B is non-zero");
      test_case(2, $urandom_range(1, max_value - 1), 0, 0, "Validate subtraction when A is non-zero and B = 0");
      A_int = $urandom_range(0, max_value - 1);
      test_case(3, A_int, A_int, 0, "Validate subtraction when A = B (should result in 0)");
      test_case(4, max_value - 1, 1, 1, "Validate addition with overflow condition");
      test_case(5, max_value / 2, max_value / 2 - 1, 1, "Validate addition without overflow");
      test_case(6, max_value - 1, max_value - 1, 1, "Validate addition with full overflow");
      test_case(7, 1, max_value - 1, 0, "Validate subtraction with negative borrow");
      if (N >= 4) begin
        test_case(8, 9999, 9999, 1, "Validate addition when A and B are both maximum values");
        test_case(9, 9999, 9999, 0, "Validate subtraction when A and B are both maximum values");
      end
      if (N >= 1) begin
        test_case(10, 9, 1, 1, "Validate single-digit wrap around during addition");
      end
      if (N >= 4) begin
        test_case(11, 1000, 1, 0, "Validate borrow propagation across multiple digits");
      end

      // Random Tests (Existing Code)
      for (i = 0; i < 100; i = i + 1) begin
        A_int = $urandom % max_value;
        B_int = $urandom % max_value;

        test_case(i + 12, A_int, B_int, $urandom % 2, "Random test case");
      end
    end
  endtask

  initial begin
    $dumpfile("multi_digit_bcd_add_sub.vcd"); // Specify the VCD file for waveform dumping
    $dumpvars(0, tb_multi_digit_bcd_add_sub); // Dump all variables in the testbench
  end

endmodule