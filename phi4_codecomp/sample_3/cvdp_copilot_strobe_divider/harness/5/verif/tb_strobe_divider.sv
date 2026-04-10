`timescale 1ns / 1ps

module tb_strobe_divider;

    // Parameters for the Device Under Test (DUT)
    parameter integer MaxRatio_g = 8; // Adjust as needed

    // Clock period definition
    parameter Clk_Period = 10; // 100MHz clock

    // DUT Ports for Latency_g = 0
    reg                      Clk_0;
    reg                      Rst_0;
    reg  [log2ceil(MaxRatio_g)-1:0] In_Ratio_0;
    reg                      In_Valid_0;
    wire                     Out_Valid_0;
    reg                      Out_Ready_0;

    // DUT Ports for Latency_g = 1
    reg                      Clk_1;
    reg                      Rst_1;
    reg  [log2ceil(MaxRatio_g)-1:0] In_Ratio_1;
    reg                      In_Valid_1;
    wire                     Out_Valid_1;
    reg                      Out_Ready_1;

    // Instantiate the DUT with Latency_g = 0
    strobe_divider #(
        .MaxRatio_g(MaxRatio_g),
        .Latency_g(0)
    ) DUT_Latency0 (
        .Clk(Clk_0),
        .Rst(Rst_0),
        .In_Ratio(In_Ratio_0),
        .In_Valid(In_Valid_0),
        .Out_Valid(Out_Valid_0),
        .Out_Ready(Out_Ready_0)
    );

    // Instantiate the DUT with Latency_g = 1
    strobe_divider #(
        .MaxRatio_g(MaxRatio_g),
        .Latency_g(1)
    ) DUT_Latency1 (
        .Clk(Clk_1),
        .Rst(Rst_1),
        .In_Ratio(In_Ratio_1),
        .In_Valid(In_Valid_1),
        .Out_Valid(Out_Valid_1),
        .Out_Ready(Out_Ready_1)
    );

    // Function to calculate the ceiling of log2
    function integer log2ceil;
        input integer value;
        integer i;
        begin
            log2ceil = 1;
            for (i = 0; (2**i) < value; i = i + 1)
                log2ceil = i + 1;
        end
    endfunction

    // Initialize Pass/Fail Counters
    integer pass_count;
    integer fail_count;

    // Additional Registers for Tracking
    reg [31:0] count_valid_0;
    reg [31:0] count_valid_1;
    reg        expected_out_valid_1;
    reg        reset_wait_0;
    reg        reset_wait_1;

    initial begin
        pass_count = 0;
        fail_count = 0;
        count_valid_0 = 0;
        count_valid_1 = 0;
        expected_out_valid_1 = 0;
        reset_wait_0 = 0;
        reset_wait_1 = 0;
    end

    // Clock Generation for DUT_Latency0
    initial begin
        Clk_0 = 0;
        forever #(Clk_Period/2) Clk_0 = ~Clk_0;
    end

    // Clock Generation for DUT_Latency1
    initial begin
        Clk_1 = 0;
        forever #(Clk_Period/2) Clk_1 = ~Clk_1;
    end

    // Initialize Inputs and VCD Dump
    initial begin
        // Initialize Inputs for Latency=0
        Rst_0        = 1;
        In_Ratio_0   = 0;
        In_Valid_0   = 0;
        Out_Ready_0  = 1; // Assume the receiver is always ready initially

        // Initialize Inputs for Latency=1
        Rst_1        = 1;
        In_Ratio_1   = 0;
        In_Valid_1   = 0;
        Out_Ready_1  = 1; // Assume the receiver is always ready initially

        // Initialize VCD Dump
        $dumpfile("tb_strobe_divider.vcd");
        $dumpvars(0, tb_strobe_divider);

        // Apply Reset to both DUTs
        #(Clk_Period * 2);
        Rst_0 = 0;
        Rst_1 = 0;

        // Start Test Sequences
        apply_test_cases();
    end

    // Monitor Outputs for DUT_Latency0
    initial begin
        $display("Starting simulation...");
        $monitor("Latency=0 | Time=%0t | Rst=%b | In_Ratio=%b | In_Valid=%b | Out_Valid=%b | Out_Ready=%b",
                 $time, Rst_0, In_Ratio_0, In_Valid_0, Out_Valid_0, Out_Ready_0);
    end

    // Monitor Outputs for DUT_Latency1
    initial begin
        $monitor("Latency=1 | Time=%0t | Rst=%b | In_Ratio=%b | In_Valid=%b | Out_Valid=%b | Out_Ready=%b",
                 $time, Rst_1, In_Ratio_1, In_Valid_1, Out_Valid_1, Out_Ready_1);
    end

    // Always block to handle Latency=0 pass/fail checks
    always @(posedge Clk_0) begin
        if (Rst_0) begin
            count_valid_0 <= 0;
            reset_wait_0 <= 1; // Skip checks immediately after reset
        end else begin
            if (reset_wait_0) begin
                reset_wait_0 <= 0; // Skip one cycle after reset
            end else begin
                if (In_Valid_0) begin
                    count_valid_0 <= count_valid_0 + 1;
                    if (count_valid_0 >= In_Ratio_0) begin
                        if (Out_Valid_0) begin
                            pass_count = pass_count + 1;
                        end else begin
                            fail_count = fail_count + 1;
                            $display("ERROR: Latency=0 | Time=%0t | Out_Valid_0 expected HIGH but was LOW", $time);
                        end
                        count_valid_0 <= 0;
                    end
                end
            end
        end
    end

    // Always block to handle Latency=1 pass/fail checks
    always @(posedge Clk_1) begin
        if (Rst_1) begin
            count_valid_1        <= 0;
            expected_out_valid_1 <= 0;
            reset_wait_1         <= 1; // Skip checks immediately after reset
        end else begin
            if (reset_wait_1) begin
                reset_wait_1 <= 0; // Skip one cycle after reset
            end else begin
                if (In_Valid_1) begin
                    count_valid_1 <= count_valid_1 + 1;
                    if (count_valid_1 >= In_Ratio_1) begin
                        expected_out_valid_1 <= 1;
                        count_valid_1 <= 0;
                    end
                end

                if (expected_out_valid_1) begin
                    if (Out_Valid_1 && Out_Ready_1) begin
                        pass_count = pass_count + 1;
                        expected_out_valid_1 <= 0;
                    end else if (!Out_Ready_1) begin
                        // Wait until Out_Ready_1 is high again
                        expected_out_valid_1 <= 1;
                    end else begin
                        fail_count = fail_count + 1;
                        $display("ERROR: Latency=1 | Time=%0t | Out_Valid_1 expected HIGH and Out_Ready_1 HIGH but was LOW", $time);
                        expected_out_valid_1 <= 0;
                    end
                end
            end
        end
    end

    // Task to Apply Test Cases
    task apply_test_cases;
        begin
            // Test Case 1: MaxRatio_g = 1 (Edge Case) for Latency=0
            $display("\n=== Test Case 1: MaxRatio_g = 1 (Latency=0) ===");
            In_Ratio_0 = 1 - 1; // In_Ratio = 0
            apply_strobe_divider(0, 5, 1, -1, 0);

            // Test Case 2: MaxRatio_g = 1 (Edge Case) for Latency=1
            $display("\n=== Test Case 2: MaxRatio_g = 1 (Latency=1) ===");
            In_Ratio_1 = 1 - 1; // In_Ratio = 0
            apply_strobe_divider(1, 5, 1, -1, 0);

            // Test Case 3: Latency_g = 0 with In_Ratio = 3
            $display("\n=== Test Case 3: Latency_g = 0, In_Ratio = 3 ===");
            In_Ratio_0 = 3; // Forward every 4th pulse (0-based)
            apply_strobe_divider(0, 16, 1, -1, 0);

            // Test Case 4: Latency_g = 1 with In_Ratio = 2
            $display("\n=== Test Case 4: Latency_g = 1, In_Ratio = 2 ===");
            In_Ratio_1 = 2; // Forward every 3rd pulse
            apply_strobe_divider(1, 12, 1, -1, 0);

            // Test Case 5: Various In_Ratio Values for Latency=0
            $display("\n=== Test Case 5: Various In_Ratio Values (Latency=0) ===");
            In_Ratio_0 = 2;
            apply_strobe_divider(0, 8, 1, -1, 0);
            In_Ratio_0 = 4;
            apply_strobe_divider(0, 8, 1, -1, 0);

            // Test Case 6: Various In_Ratio Values for Latency=1
            $display("\n=== Test Case 6: Various In_Ratio Values (Latency=1) ===");
            In_Ratio_1 = 2;
            apply_strobe_divider(1, 8, 1, -1, 0);
            In_Ratio_1 = 4;
            apply_strobe_divider(1, 8, 1, -1, 0);

            // Test Case 7: In_Valid Pulses with Gaps for Latency=0
            $display("\n=== Test Case 7: In_Valid Pulses with Gaps (Latency=0) ===");
            In_Ratio_0 = 4;
            apply_strobe_divider(0, 20, 3, -1, 0);

            // Test Case 8: In_Valid Pulses with Gaps for Latency=1
            $display("\n=== Test Case 8: In_Valid Pulses with Gaps (Latency=1) ===");
            In_Ratio_1 = 4;
            apply_strobe_divider(1, 20, 3, -1, 0);

            // Test Case 9: Reset During Operation for Latency=0
            $display("\n=== Test Case 9: Reset During Operation (Latency=0) ===");
            In_Ratio_0 = 5;
            apply_strobe_divider(0, 5, 1, -1, 0);
            apply_reset(0);
            apply_strobe_divider(0, 10, 1, -1, 0);

            // Test Case 10: Reset During Operation for Latency=1
            $display("\n=== Test Case 10: Reset During Operation (Latency=1) ===");
            In_Ratio_1 = 5;
            apply_strobe_divider(1, 5, 1, -1, 0);
            apply_reset(1);
            apply_strobe_divider(1, 10, 1, -1, 0);

            // Test Case 11: Out_Ready Deassertion for Latency=0
            $display("\n=== Test Case 11: Out_Ready Deassertion (Latency=0) ===");
            In_Ratio_0 = 3;
            apply_strobe_divider_with_out_ready(0, 10, 5);

            // Test Case 12: Out_Ready Deassertion for Latency=1
            $display("\n=== Test Case 12: Out_Ready Deassertion (Latency=1) ===");
            In_Ratio_1 = 3;
            apply_strobe_divider_with_out_ready(1, 10, 5);

            // Finish Simulation
            $display("\n=== Simulation Complete ===");
            $display("Pass Count: %0d | Fail Count: %0d", pass_count, fail_count);
            if (fail_count == 0) begin
                $display("ALL TESTS PASSED.");
            end else begin
                $display("SOME TESTS FAILED.");
            end
            $finish;
        end
    endtask

    // Task to Apply Strobe Divider Test
    // Parameters:
    //   latency: 0 or 1
    //   cycles: number of clock cycles to apply
    //   toggle_valid: how often to toggle In_Valid (e.g., 1: every cycle, 3: every 3 cycles)
    //   out_ready_deassert_at: cycle number to deassert Out_Ready (optional, -1: never)
    //   reset_flag: 1 to apply reset, 0 otherwise
    task apply_strobe_divider;
        input integer latency;
        input integer cycles;
        input integer toggle_valid;
        input integer out_ready_deassert_at; // Cycle at which to deassert Out_Ready
        input integer reset_flag; // 1 to reset, 0 otherwise
        integer j;
        begin
            for (j = 0; j < cycles; j = j + 1) begin
                @(posedge (latency == 0 ? Clk_0 : Clk_1));

                // Apply Reset if needed
                if (reset_flag) begin
                    if (latency == 0) begin
                        Rst_0 <= 1;
                    end else begin
                        Rst_1 <= 1;
                    end
                end else begin
                    if (latency == 0) begin
                        Rst_0 <= 0;
                    end else begin
                        Rst_1 <= 0;
                    end
                end

                // Toggle In_Valid based on toggle_valid parameter
                if (toggle_valid > 0) begin
                    if (j % toggle_valid == 0) begin
                        if (latency == 0) begin
                            In_Valid_0 <= 1;
                        end else begin
                            In_Valid_1 <= 1;
                        end
                    end else begin
                        if (latency == 0) begin
                            In_Valid_0 <= 0;
                        end else begin
                            In_Valid_1 <= 0;
                        end
                    end
                end else begin
                    // Fixed In_Valid = 1
                    if (latency == 0) begin
                        In_Valid_0 <= 1;
                    end else begin
                        In_Valid_1 <= 1;
                    end
                end

                // Deassert Out_Ready at specified cycle
                if (j == out_ready_deassert_at) begin
                    if (latency == 0) begin
                        Out_Ready_0 <= 0;
                    end else begin
                        Out_Ready_1 <= 0;
                    end
                end else begin
                    if (latency == 0) begin
                        Out_Ready_0 <= 1;
                    end else begin
                        Out_Ready_1 <= 1;
                    end
                end
            end
        end
    endtask

    // Task to Apply Strobe Divider with Out_Ready Deassertion
    // Parameters:
    //   latency: 0 or 1
    //   cycles: number of clock cycles to apply
    //   deassert_at: cycle number to deassert Out_Ready
    task apply_strobe_divider_with_out_ready;
        input integer latency;
        input integer cycles;
        input integer deassert_at;
        integer k;
        begin
            for (k = 0; k < cycles; k = k + 1) begin
                @(posedge (latency == 0 ? Clk_0 : Clk_1));

                // Apply In_Valid (toggle every cycle)
                if (k % 2 == 0) begin
                    if (latency == 0) begin
                        In_Valid_0 <= 1;
                    end else begin
                        In_Valid_1 <= 1;
                    end
                end else begin
                    if (latency == 0) begin
                        In_Valid_0 <= 0;
                    end else begin
                        In_Valid_1 <= 0;
                    end
                end

                // Deassert Out_Ready at specified cycle
                if (k == deassert_at) begin
                    if (latency == 0) begin
                        Out_Ready_0 <= 0;
                    end else begin
                        Out_Ready_1 <= 0;
                    end
                end else begin
                    if (latency == 0) begin
                        Out_Ready_0 <= 1;
                    end else begin
                        Out_Ready_1 <= 1;
                    end
                end
            end
        end
    endtask

    // Task to Apply Reset
    task apply_reset;
        input integer latency;
        begin
            if (latency == 0) begin
                Rst_0 = 1;
                @(posedge Clk_0);
                @(posedge Clk_0);
                Rst_0 = 0;
            end else begin
                Rst_1 = 1;
                @(posedge Clk_1);
                @(posedge Clk_1);
                Rst_1 = 0;
            end
        end
    endtask

endmodule