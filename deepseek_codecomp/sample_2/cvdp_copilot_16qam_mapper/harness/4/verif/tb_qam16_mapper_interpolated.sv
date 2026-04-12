module tb_qam16_mapper_interpolated;

    // Parameters
    parameter N = 4;            // Number of input symbols
    parameter IN_WIDTH = 4;     // Width of each input symbol
    parameter OUT_WIDTH = 3;    // Width of each output value

    // DUT Ports
    logic [N*IN_WIDTH-1:0] bits;            
    logic signed [(N + N/2)*OUT_WIDTH-1:0] I;
    logic signed [(N + N/2)*OUT_WIDTH-1:0] Q;

    // Instantiate DUT
    qam16_mapper_interpolated #(
        .N(N),
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) dut (
        .bits(bits),
        .I(I),
        .Q(Q)
    );

    // Testbench variables
    logic [3:0] test_symbols [0:N-1]; // Holds individual test symbols
    logic signed [OUT_WIDTH-1:0] model_I [0:(N + N/2)-1];
    logic signed [OUT_WIDTH-1:0] model_Q [0:(N + N/2)-1];

    // Counters for test results
    int total_tests = 0;
    int passed_tests = 0;
    int failed_tests = 0;

    // Function to apply inputs
    task apply_inputs(input logic [N*IN_WIDTH-1:0] test_bits);
        bits = test_bits;
        #10;  // Wait for stabilization
    endtask

    // Function to compute expected outputs (model of the system)
    task model_system();
        logic signed [OUT_WIDTH-1:0] mapped_I [0:N-1];
        logic signed [OUT_WIDTH-1:0] mapped_Q [0:N-1];
        logic signed [OUT_WIDTH:0] interp_I [0:N/2-1];
        logic signed [OUT_WIDTH:0] interp_Q [0:N/2-1];

        // Map symbols
        for (int i = 0; i < N; i++) begin
            case (test_symbols[i][3:2])
                2'b00: mapped_I[i] = -3;
                2'b01: mapped_I[i] = -1;
                2'b10: mapped_I[i] = 1;
                2'b11: mapped_I[i] = 3;
            endcase
            case (test_symbols[i][1:0])
                2'b00: mapped_Q[i] = -3;
                2'b01: mapped_Q[i] = -1;
                2'b10: mapped_Q[i] = 1;
                2'b11: mapped_Q[i] = 3;
            endcase
        end

        // Interpolate
        for (int i = 0; i < N/2; i++) begin
            interp_I[i] = (mapped_I[2*i] + mapped_I[2*i+1]) >>> 1;
            interp_Q[i] = (mapped_Q[2*i] + mapped_Q[2*i+1]) >>> 1;
        end

        // Build output
        for (int i = 0; i < N/2; i++) begin
            model_I[i*3]     = mapped_I[2*i];
            model_I[i*3 + 1] = interp_I[i];
            model_I[i*3 + 2] = mapped_I[2*i+1];

            model_Q[i*3]     = mapped_Q[2*i];
            model_Q[i*3 + 1] = interp_Q[i];
            model_Q[i*3 + 2] = mapped_Q[2*i+1];
        end
    endtask

    // Function to check outputs
    task check_outputs();
        int failed = 0;
        for (int i = 0; i < (N + N/2); i++) begin
            if ($signed(I[(i+1)*OUT_WIDTH-1 -: OUT_WIDTH]) !== model_I[i]) begin
                $error("Mismatch in I[%0d]: DUT=%0d, Expected=%0d", i, $signed(I[(i+1)*OUT_WIDTH-1 -: OUT_WIDTH]), model_I[i]);
                failed = 1;
            end
            if ($signed(Q[(i+1)*OUT_WIDTH-1 -: OUT_WIDTH]) !== model_Q[i]) begin
                $error("Mismatch in Q[%0d]: DUT=%0d, Expected=%0d", i, $signed(Q[(i+1)*OUT_WIDTH-1 -: OUT_WIDTH]), model_Q[i]);
                failed = 1;
            end
        end
        if (failed == 0) passed_tests++;
        else failed_tests++;
        total_tests++;
    endtask

    // Simulation control
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_qam16_mapper_interpolated);

        // Iterate over all possible combinations of inputs
        for (int s0 = 0; s0 < 16; s0++) begin
            for (int s1 = 0; s1 < 16; s1++) begin
                for (int s2 = 0; s2 < 16; s2++) begin
                    for (int s3 = 0; s3 < 16; s3++) begin
                        test_symbols[0] = s0;
                        test_symbols[1] = s1;
                        test_symbols[2] = s2;
                        test_symbols[3] = s3;

                        // Pack test_symbols into bits
                        apply_inputs({
                            test_symbols[3],
                            test_symbols[2],
                            test_symbols[1],
                            test_symbols[0]
                        });

                        // Compute expected outputs
                        model_system();

                        // Check DUT outputs
                        check_outputs();
                    end
                end
            end
        end

        // Print summary
        $display("==================================");
        $display("Test Summary:");
        $display("Total Tests   : %0d", total_tests);
        $display("Passed Tests  : %0d", passed_tests);
        $display("Failed Tests  : %0d", failed_tests);
        $display("==================================");

        if (failed_tests == 0)
            $display("All tests passed successfully!");
        else
            $display("Some tests failed. Check the logs.");

        $finish;
    end
endmodule