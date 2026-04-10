module TestBench #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32,
    parameter COUNTERW = 2
);

    // Local parameters
    localparam int MAX_FREQUENCY = (1 << COUNTERW) - 1;

    // Clock and reset
    logic clock;
    logic reset;

    // DUT signals
    logic [$clog2(NINDEXES)-1:0] index;
    logic [$clog2(NWAYS)-1:0] way_select;
    logic access;
    logic hit;
    wire [$clog2(NWAYS)-1:0] way_replace;

    // Auxiliary signals
    logic [$clog2(NWAYS)-1:0] other_way_1, other_way_2, target_way;

    // DUT instantiation
    lfu_counter_policy #(
        .NWAYS(NWAYS),
        .NINDEXES(NINDEXES),
        .COUNTERW(COUNTERW)
    ) dut (
        .clock(clock),
        .reset(reset),
        .index(index),
        .way_select(way_select),
        .access(access),
        .hit(hit),
        .way_replace(way_replace)
    );

    // Clock generation
    initial clock = 0;
    always #5 clock = ~clock;

    // Reset task
    task apply_reset;
        begin
            reset = 1;
            #10;
            reset = 0;
            #10;
        end
    endtask

    // Initialize
    task run_tests;
        begin
            $display("Instance with parameters: NWAYS=%0d, NINDEXES=%0d, COUNTERW=%0d", NWAYS, NINDEXES, COUNTERW);
            run_reset_test();
            run_hit_behavior_test();
            run_miss_behavior_test();
        end
    endtask

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, lfu_counter_policy_tb);
    end

    // Test tasks
    task run_reset_test;
        begin
            integer error;
            error = 0;

            $display("Running Reset Test...");
            apply_reset();

            @(posedge clock);
            for (int i = 0; i < NINDEXES; i = i + 1) begin
                for (int n = 0; n < NWAYS; n = n + 1) begin
                    assert (dut.frequency[i][(n * COUNTERW) +: COUNTERW] == COUNTERW'(0))
                    else begin
                        error = 1;
                        $error("Reset Test Failed: frequency for index=%0d way=%0d (%0d) != 0",
                            i, n, dut.frequency[i][(n * COUNTERW) +: COUNTERW]);
                    end
                end
            end
            if (error == 0) begin
                $display("Reset Test Passed.");
            end
        end
    endtask

    task run_hit_behavior_test;
        begin
            integer previous_frequency;
            integer error;
            error = 0;

            $display("Running Hit Behavior Test...");
            apply_reset();

            $display("- Hit after reset increases the frequency counter...");
            @(negedge clock);
            index = 0;
            way_select = 1;
            hit = 1;
            access = 1;
            assert (dut.frequency[index][(way_select * COUNTERW) +: COUNTERW] == COUNTERW'(0))
            else begin
                error = 1;
                $error("Hit Test Failed: index=%0d, way=%0d is supposed to be reset", index, way_select);
            end

            @(negedge clock);
            hit = 0;
            access = 0;

            assert (dut.frequency[index][(way_select * COUNTERW) +: COUNTERW] == COUNTERW'(1))
            else begin
                error = 1;
                $error("Hit Test Failed: index=%0d, way=%0d frequency is supposed to be 1, but got %0d",
                    index, way_select, dut.frequency[index][(way_select * COUNTERW) +: COUNTERW]);
            end

            $display("- Hit with counter equals to MAX_FREQUENCY...");
            @(negedge clock);
            index = 0;
            way_select = 3;
            other_way_1 = 2;
            other_way_2 = 1;
            hit = 1;
            access = 1;
            dut.frequency[index][(way_select * COUNTERW) +: COUNTERW] = COUNTERW'(MAX_FREQUENCY);
            dut.frequency[index][(other_way_1 * COUNTERW) +: COUNTERW] = COUNTERW'(MAX_FREQUENCY);
            dut.frequency[index][(other_way_2 * COUNTERW) +: COUNTERW] = COUNTERW'(3);

            @(negedge clock);
            hit = 0;
            access = 0;

            assert (dut.frequency[index][(way_select * COUNTERW) +: COUNTERW] == COUNTERW'(MAX_FREQUENCY))
            else begin
                error = 1;
                $error("Hit Test Failed: index=%0d, way=%0d frequency is supposed to be MAX_FREQUENCY(%0d), but got %0d",
                    index, way_select, MAX_FREQUENCY, dut.frequency[index][(way_select * COUNTERW) +: COUNTERW]);
            end

            assert (dut.frequency[index][(other_way_1 * COUNTERW) +: COUNTERW] == COUNTERW'(MAX_FREQUENCY-1))
            else begin
                error = 1;
                $error("Hit Test Failed: index=%0d, way=%0d frequency is supposed to be MAX_FREQUENCY-1(%0d), but got %0d",
                    index, other_way_1, MAX_FREQUENCY-1, dut.frequency[index][(other_way_1 * COUNTERW) +: COUNTERW]);
            end

            assert (dut.frequency[index][(other_way_2 * COUNTERW) +: COUNTERW] == COUNTERW'(2))
            else begin
                error = 1;
                $error("Hit Test Failed: index=%0d, way=%0d frequency is supposed to be 2, but got %0d",
                    index, other_way_2, dut.frequency[index][(other_way_2 * COUNTERW) +: COUNTERW]);
            end

            // Test hit increments the frequency counter correctly for different (random) ways and current frequencies
            for (int i = 0; i < MAX_FREQUENCY; i++) begin
                way_select = $urandom() % NWAYS;
                previous_frequency = $urandom() % $pow(2, COUNTERW);
                $display("- Hit with counter equals to any value... (way=%0d, freq=%0d)", way_select, previous_frequency);
                @(negedge clock);
                index = 0;
                dut.frequency[index][(way_select * COUNTERW) +: COUNTERW] = COUNTERW'(previous_frequency);
                hit = 1;
                access = 1;

                @(negedge clock);
                hit = 0;
                access = 0;

                if (previous_frequency == MAX_FREQUENCY) begin
                    assert (dut.frequency[index][(way_select * COUNTERW) +: COUNTERW] == COUNTERW'(MAX_FREQUENCY))
                    else begin
                        error = 1 ;
                        $error("Hit Test Failed: index=%0d, way=%0d frequency is supposed to be MAX_FREQUENCY(%0d), but got %0d",
                            index, way_select, MAX_FREQUENCY, dut.frequency[index][(way_select * COUNTERW) +: COUNTERW]);
                    end
                end else begin
                    assert (dut.frequency[index][(way_select * COUNTERW) +: COUNTERW] == COUNTERW'(previous_frequency + 1))
                    else begin
                        error = 1;
                        $error("Hit Test Failed: index=%0d, way=%0d frequency is supposed to be %0d, but got %0d",
                            index, way_select, previous_frequency + 1, dut.frequency[index][(way_select * COUNTERW) +: COUNTERW]);
                    end
                end
            end

            if (error == 0) begin
                $display("Hit Behavior Test Passed.");
            end
        end
    endtask

    task run_miss_behavior_test;
        begin
            integer error;
            error = 0;

            $display("Running Miss Behavior Test...");
            apply_reset();

            $display("- Miss replaces the least frequently used, least way in order...");
            @(negedge clock);
            index = 1;
            target_way = 0;
            other_way_1 = 1;
            other_way_2 = 2;
            way_select = other_way_2;
            hit = 0;
            access = 1;

            // Set initial frequencies
            dut.frequency[index][(target_way * COUNTERW) +: COUNTERW] = COUNTERW'(0);
            dut.frequency[index][(other_way_1 * COUNTERW) +: COUNTERW] = COUNTERW'(MAX_FREQUENCY);
            dut.frequency[index][(other_way_2 * COUNTERW) +: COUNTERW] = COUNTERW'(0);
            for (int i = 3; i < NWAYS; i++) begin
                dut.frequency[index][(i * COUNTERW) +: COUNTERW] = COUNTERW'($urandom_range(1, MAX_FREQUENCY));
            end
            assert (dut.way_replace == target_way)
            else begin
                error = 1;
                $error("Miss Test Failed: way_replace != %0d", target_way);
            end

            @(negedge clock);
            access = 0;

            assert (dut.frequency[index][(target_way * COUNTERW) +: COUNTERW] == COUNTERW'(1))
            else begin
                error = 1;
                $error("Miss Test Failed: the frequency counter of replaced way was not initialized to 1");
            end

            assert (dut.way_replace == other_way_2)
            else begin
                error = 1;
                $error("Miss Test Failed: way_replace != %0d", other_way_2);
            end

            if (error == 0) begin
                $display("Miss Behavior Test Passed.");
            end
        end
    endtask

endmodule : TestBench

module lfu_counter_policy_tb;

    TestBench #() test_bench_0(); // test with default parameter values
    TestBench #(
        .NWAYS(8),
        .NINDEXES(64),
        .COUNTERW(3)
    ) test_bench_1();
    TestBench #(
        .NWAYS(8),
        .NINDEXES(64),
        .COUNTERW(4)
    ) test_bench_2();

    initial begin
        $display("Starting testbench...");

        test_bench_0.run_tests();
        test_bench_1.run_tests();
        test_bench_2.run_tests();

        $display("All tests completed.");
        $finish;
    end

endmodule : lfu_counter_policy_tb