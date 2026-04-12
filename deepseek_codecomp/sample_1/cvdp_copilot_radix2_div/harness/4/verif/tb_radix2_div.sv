`timescale 1ns / 1ps

module tb_verified_radix2_div;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] dividend;
    reg [7:0] divisor;

    // Outputs
    wire [7:0] quotient;
    wire [7:0] remainder;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    radix2_div uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .done(done)
    );

    // Waveform Dump
    initial begin
        $dumpfile("waveform.vcd");                // Specify the name of the dump file
        $dumpvars(0, tb_verified_radix2_div);     // Dump all variables in this testbench
    end

    // Clock generation: 100MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 ns
    end

    // Testbench procedure
    initial begin
        // Apply reset
        rst_n = 0;
        start = 0;
        dividend = 8'd0;
        divisor = 8'd0;
        #20; // Wait for 20 ns
        rst_n = 1;

        // Wait for global reset to finish
        #10;

        // Predefined Test Cases
        perform_test(8'd100, 8'd10);
        perform_test(8'd255, 8'd15);
        perform_test(8'd0,   8'd1);
        perform_test(8'd1,   8'd0);  // Divide by zero
        perform_test(8'd50,  8'd25);
        perform_test(8'd200, 8'd20);
        perform_test(8'd128, 8'd64);
        perform_test(8'd255, 8'd1);
        perform_test(8'd1,   8'd255);
        perform_test(8'd128, 8'd128);
        perform_test(8'd15,  8'd4);
        perform_test(8'd255, 8'd255);
        perform_test(8'd250, 8'd5);
        perform_test(8'd77,  8'd7);
        perform_test(8'd123, 8'd11);
        perform_test(8'd90,  8'd9);

        // Random Test Cases
        $display("\nStarting Random Test Cases...\n");
        repeat (10) begin
            // Generate random dividend and divisor
            reg [7:0] rand_dividend;
            reg [7:0] rand_divisor;
            rand_dividend = $random % 256;           // 0 to 255
            rand_divisor  = ($random % 255) + 1;     // 1 to 255 (avoiding zero)

            // Perform the random test
            perform_test(rand_dividend, rand_divisor);
        end

        // Finish simulation
        $finish;
    end

    // Task to perform a single test
    task perform_test;
        input [7:0] dividend_in;
        input [7:0] divisor_in;
        reg [7:0] expected_quotient;
        reg [7:0] expected_remainder;
    begin
        // Apply inputs
        @(negedge clk); // Wait for falling edge of clock
        dividend = dividend_in;
        divisor = divisor_in;
        start = 1;
        #10; // Hold start high for one clock cycle
        start = 0;

        // Wait for division to complete
        wait (done);

        // Compute expected values
        if (divisor_in != 0) begin
            expected_quotient = dividend_in / divisor_in;
            expected_remainder = dividend_in % divisor_in;
        end else begin
            expected_quotient = 8'hFF;  // Indicate error for divide by zero
            expected_remainder = 8'hFF;
        end

        // Check results and Print
        $display("Test Case: Dividend = %d, Divisor = %d", dividend_in, divisor_in);
        $display("Expected Quotient = %d, Expected Remainder = %d", expected_quotient, expected_remainder);
        $display("Received Quotient = %d, Received Remainder = %d", quotient, remainder);

        if (quotient !== expected_quotient || remainder !== expected_remainder) begin
            $display("** Test FAILED **\n");
        end else begin
            $display("** Test PASSED **\n");
        end

        // Small delay before next test
        #20;
    end
    endtask

endmodule