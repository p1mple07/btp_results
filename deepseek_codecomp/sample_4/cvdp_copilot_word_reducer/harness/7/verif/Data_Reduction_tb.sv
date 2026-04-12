`timescale 1ns / 1ps

module tb_Data_Reduction;

    // Parameters for the testbench
    parameter [2:0] REDUCTION_OP = 3'b101; // Default: XNOR
    parameter DATA_WIDTH = 8;              // Width of each data element
    parameter DATA_COUNT = 4;              // Number of data elements
    localparam TOTAL_INPUT_WIDTH = DATA_WIDTH * DATA_COUNT;

    // Testbench signals
    reg  [TOTAL_INPUT_WIDTH-1:0] data_in; 
    wire [DATA_WIDTH-1:0]        reduced_data_out;

    // Instantiate the DUT
    Data_Reduction #(
        .REDUCTION_OP(REDUCTION_OP),
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_COUNT(DATA_COUNT)
    ) dut (
        .data_in(data_in),
        .reduced_data_out(reduced_data_out)
    );

    integer total_tests = 0;
    integer passed_tests = 0;
    integer failed_tests = 0;

    function [DATA_WIDTH-1:0] compute_expected_output(input [TOTAL_INPUT_WIDTH-1:0] input_data);
        reg [DATA_WIDTH-1:0] words [0:DATA_COUNT-1];
        reg [DATA_WIDTH-1:0] temp_result;
        integer i;
        begin
            for (i = 0; i < DATA_COUNT; i = i + 1) begin
                words[i] = input_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
            end
            temp_result = words[0];

            for (i = 1; i < DATA_COUNT; i = i + 1) begin
                case (REDUCTION_OP)
                    3'b000, 3'b011: temp_result = temp_result & words[i]; 
                    3'b001, 3'b100: temp_result = temp_result | words[i]; 
                    3'b010, 3'b101: temp_result = temp_result ^ words[i]; 
                    default: temp_result = temp_result & words[i]; 
                endcase
            end

            if (REDUCTION_OP == 3'b011 || REDUCTION_OP == 3'b100 || REDUCTION_OP == 3'b101) begin
                compute_expected_output = ~temp_result; 
            end else begin
                compute_expected_output = temp_result;
            end
        end
    endfunction

    task validate_output(
        input [TOTAL_INPUT_WIDTH-1:0] test_data,
        input [DATA_WIDTH-1:0] expected_output
    );
        begin
            data_in = test_data;
            #10; 

            total_tests += 1;
            if (reduced_data_out === expected_output) begin
                passed_tests += 1;
                $display("[PASS]: data_in=%b -> expected=%b, got=%b",
                         test_data, expected_output, reduced_data_out);
            end else begin
                failed_tests += 1;
                $error("[FAIL]: data_in=%b -> expected=%b, got=%b",
                       test_data, expected_output, reduced_data_out);
            end
        end
    endtask

    task test_specific_cases;
        begin
            $display("Starting Specific Case Testing...");
            validate_output({TOTAL_INPUT_WIDTH{1'b0}}, compute_expected_output({TOTAL_INPUT_WIDTH{1'b0}}));
            validate_output({TOTAL_INPUT_WIDTH{1'b1}}, compute_expected_output({TOTAL_INPUT_WIDTH{1'b1}}));
            validate_output({TOTAL_INPUT_WIDTH{4'b1010}}, compute_expected_output({TOTAL_INPUT_WIDTH{4'b1010}}));
            validate_output({TOTAL_INPUT_WIDTH{4'b0101}}, compute_expected_output({TOTAL_INPUT_WIDTH{4'b0101}}));

            for (int i = 0; i < TOTAL_INPUT_WIDTH; i++) begin
                validate_output(1 << i, compute_expected_output(1 << i));
            end
        end
    endtask

    task test_random_inputs;
        integer i;
        reg [TOTAL_INPUT_WIDTH-1:0] random_data;
        begin
            $display("Starting Randomized Testing...");
            for (i = 0; i < 100; i++) begin
                random_data = $urandom;
                validate_output(random_data, compute_expected_output(random_data));
            end
        end
    endtask

    task print_summary;
        begin
            $display("=================================================");
            $display("Test Summary:");
            $display("Total Tests Run: %0d", total_tests);
            $display("Tests Passed   : %0d", passed_tests);
            $display("Tests Failed   : %0d", failed_tests);
            $display("=================================================");
            if (failed_tests > 0) begin
                $error("Some tests failed. Check the logs for details.");
            end else begin
                $display("All tests passed successfully!");
            end
        end
    endtask

    initial begin
        $display("Starting testbench for Data_Reduction...");
        test_specific_cases();
        test_random_inputs();
        print_summary();

        $finish;
    end

endmodule