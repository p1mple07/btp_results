module tb_continuous_adder;

    // Testbench parameters
    parameter DATA_WIDTH = 32;
    parameter THRESHOLD_VALUE = 200;
    parameter SIGNED_INPUTS = 1;  // 1 for signed inputs, 0 for unsigned inputs

    // Testbench signals
    logic                        clk;          // Clock signal
    logic                        reset;        // Reset signal
    logic signed [DATA_WIDTH-1:0] data_in;     // Input data
    logic                        data_valid;   // Data valid signal
    logic signed [DATA_WIDTH-1:0] sum_out;     // Accumulated sum output
    logic                        sum_ready;    // Signal indicating sum is output and accumulator is reset

    // Clock generation: 10ns period (50MHz)
    always #5 clk = ~clk;

    // Instantiate the continuous_adder module (Unit Under Test - UUT)
    continuous_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_INPUTS(SIGNED_INPUTS),
	.THRESHOLD_VALUE(THRESHOLD_VALUE)
    ) uut (
        .clk        (clk),
        .reset      (reset),
        .data_in    (data_in),
        .data_valid (data_valid),
        .sum_out    (sum_out),
        .sum_ready  (sum_ready)
    );

    // Test procedure
    initial begin
        // Waveform dumping
        $dumpfile("waveform.vcd");  // Create the dump file
        $dumpvars(0, tb_continuous_adder);  // Dump all variables

        $display("Starting the testbench...");

        // Initialize signals
        clk = 0;
        reset = 1;  // Apply reset initially
        data_in = 0;
        data_valid = 0;

        // Apply reset and release it
        #10 reset = 0;
        #10 reset = 1;
        #10 reset = 0;

        // Test Case 1: 
        test_add_sequence(10, 20, 30, 40,10, 20, 30, 40);
        check_output(THRESHOLD_VALUE);
        $display("Test Case 1 passed.");

        // Test Case 2: 
        test_add_sequence(60, 0, 0, 50,60, 0, 0, 50);
        check_output(220);
        $display("Test Case 2 passed.");

        // Test Case 3: 
        test_add_sequence(50, 20, 0, 30,50, 20, 0, 30);
        check_output(THRESHOLD_VALUE);
        $display("Test Case 3 passed.");

        // Test Case 4: 
        if (SIGNED_INPUTS) begin
            test_add_sequence(-30, -40, 20, 150,-30, -40, 20, 150);
            check_output(THRESHOLD_VALUE);
            $display("Test Case 4 (negative inputs) passed.");
        end

        // Test Case 5: 
        if (SIGNED_INPUTS) begin
            test_add_sequence(-50, -30, 0, -40, -50, -20, 0, -50);
            check_output(-240);
            $display("Test Case 5 (negative sum exceeded -200) passed.");
        end

        $display("All test cases completed.");
        $finish;  // End simulation
    end

    task test_add_sequence(input logic signed [DATA_WIDTH-1:0] in1, in2, in3, in4, in5, in6, in7, in8);
        data_valid = 1;
        data_in = in1;
        #10 data_in = in2;
        #10 data_in = in3;
        #10 data_in = in4;
        #10 data_in = in5;
        #10 data_in = in6;
        #10 data_in = in7;
        #10 data_in = in8;
        #10 data_valid = 0;  
    endtask

    task check_output(input logic signed [DATA_WIDTH-1:0] expected_sum);
        #10;  
        if ((sum_out != expected_sum) || (sum_ready != 1'b1)) begin
            $error("Test failed: expected sum = %0d, got sum = %0d", expected_sum, sum_out);
        end else begin
            $display("Test passed: expected sum = %0d, got sum = %0d", expected_sum, sum_out);
        end
    endtask

endmodule