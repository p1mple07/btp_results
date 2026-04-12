module tb_arithmetic_progression_generator;

    // Sequence 1 parameters
    parameter DATA_WIDTH_1 = 16;
    parameter SEQUENCE_LENGTH_1 = 5;
    localparam WIDTH_OUT_VAL_1 = $clog2(SEQUENCE_LENGTH_1) + DATA_WIDTH_1; // Bit width of out_val to prevent overflow


    // Sequence 2 parameters
    parameter DATA_WIDTH_2 = 8;
    parameter SEQUENCE_LENGTH_2 = 10;
    logic [11 : 0] final_value = 'h9F6;
    localparam WIDTH_OUT_VAL_2 = $clog2(SEQUENCE_LENGTH_2) + DATA_WIDTH_2; // Bit width of out_val to prevent overflow


    // Sequence 3 parameters
    parameter DATA_WIDTH_3 = 12;
    parameter SEQUENCE_LENGTH_3 = 7;
    localparam WIDTH_OUT_VAL_3 = $clog2(SEQUENCE_LENGTH_3) + DATA_WIDTH_3; // Bit width of out_val to prevent overflow


    // Testbench signals
    logic clk;
    logic resetn;
    logic enable;
    logic [15:0] start_val;  // Max width needed across test cases
    logic [15:0] step_size;  // Max width needed across test cases
    logic done_1, done_2, done_3; // Done signals for each sequence
    logic [WIDTH_OUT_VAL_1-1:0] out_val_1;
    logic [WIDTH_OUT_VAL_2-1:0] out_val_2;
    logic [WIDTH_OUT_VAL_3-1:0] out_val_3;
    int cycle_counter; // Cycle counter for tracking clock cycles

    // Instantiate DUTs for each sequence
    arithmetic_progression_generator #(
        .DATA_WIDTH(DATA_WIDTH_1),
        .SEQUENCE_LENGTH(SEQUENCE_LENGTH_1)
    ) dut1 (
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .start_val(start_val[DATA_WIDTH_1-1:0]),
        .step_size(step_size[DATA_WIDTH_1-1:0]),
        .out_val(out_val_1),
        .done(done_1)
    );

    arithmetic_progression_generator #(
        .DATA_WIDTH(DATA_WIDTH_2),
        .SEQUENCE_LENGTH(SEQUENCE_LENGTH_2)
    ) dut2 (
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .start_val(start_val[DATA_WIDTH_2-1:0]),
        .step_size(step_size[DATA_WIDTH_2-1:0]),
        .out_val(out_val_2),
        .done(done_2)
    );

    arithmetic_progression_generator #(
        .DATA_WIDTH(DATA_WIDTH_3),
        .SEQUENCE_LENGTH(SEQUENCE_LENGTH_3)
    ) dut3 (
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .start_val(start_val[DATA_WIDTH_3-1:0]),
        .step_size(step_size[DATA_WIDTH_3-1:0]),
        .out_val(out_val_3),
        .done(done_3)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Test procedure
    initial begin
        // Test sequence 1, normal testing
        $display("\nRunning Test Sequence 1: DATA_WIDTH=%0d, SEQUENCE_LENGTH=%0d, Start Value=%0d, Step Size=%0d", 
                 DATA_WIDTH_1, SEQUENCE_LENGTH_1, 10, 15);
        run_test(1, 10, 15); // start_val = 10, step_size = 15

        // Test sequence 2, check for overflow 
        $display("\nRunning Test Sequence 2: DATA_WIDTH=%0d, SEQUENCE_LENGTH=%0d, Start Value=%0d, Step Size=%0d", 
                 DATA_WIDTH_2, SEQUENCE_LENGTH_2, 8'hFF , 8'hFF);
        run_test(2, 8'hFF, 8'hFF); // start_val = 5, step_size = 3

        // Test sequence 3
        $display("\nRunning Test Sequence 3: DATA_WIDTH=%0d, SEQUENCE_LENGTH=%0d, Start Value=%0d, Step Size=%0d", 
                 DATA_WIDTH_3, SEQUENCE_LENGTH_3, 20, 7);
        run_test(3, 20, 7); // start_val = 20, step_size = 7

        // End simulation
        $finish;
    end

    // Task to run individual test sequences
    task run_test(input int sequence_id, input int s_val, input int step);
        begin
            // Reset cycle counter for each sequence
            cycle_counter = 0;

            resetn = 0;
            enable = 0;
            start_val = s_val;
            step_size = step;

            // Apply reset
            #10 resetn = 1;

            // Start the progression generator
            #10 enable = 1;

            // Monitor progress for the active sequence
            if (sequence_id == 1) begin
                while (!done_1) begin
                    @(posedge clk);
                    cycle_counter++;
                    $display("Cycle: %0d | Time: %0t | resetn: %b | Start Value: %0d | Step Size: %0d | out_val: %0d | done: %b | enable: %b", 
                             cycle_counter, $time, resetn, s_val, step, out_val_1, done_1, enable);
                end
                @(posedge clk);
                cycle_counter++;
                $display("Cycle: %0d | Time: %0t | resetn: %b | Start Value: %0d | Step Size: %0d | Final out_val: %0d | done: %b | enable: %b", 
                         cycle_counter, $time, resetn, s_val, step, out_val_1, done_1, enable);
                assert (out_val_1 == 'h46 ) else $error("Wrong output");

            end else if (sequence_id == 2) begin
                while (!done_2) begin
                    @(posedge clk);
                    cycle_counter++;
                    $display("Cycle: %0d | Time: %0t | resetn: %b | Start Value: %0d | Step Size: %0d | out_val: %0d | done: %b | enable: %b", 
                             cycle_counter, $time, resetn, s_val, step, out_val_2, done_2, enable);
                end
                @(posedge clk);
                cycle_counter++;
                $display("Cycle: %0d | Time: %0t | resetn: %b | Start Value: %0d | Step Size: %0d | Final out_val: %0d | done: %b | enable: %b", 
                         cycle_counter, $time, resetn, s_val, step, out_val_2, done_2, enable);
                assert (out_val_2 == final_value ) else $error("Overflow occured!");

            end else if (sequence_id == 3) begin
                while (!done_3) begin
                    @(posedge clk);
                    cycle_counter++;
                    $display("Cycle: %0d | Time: %0t | resetn: %b | Start Value: %0d | Step Size: %0d | out_val: %0d | done: %b | enable: %b", 
                             cycle_counter, $time, resetn, s_val, step, out_val_3, done_3, enable);
                end
                @(posedge clk);
                cycle_counter++;
                $display("Cycle: %0d | Time: %0t | resetn: %b | Start Value: %0d | Step Size: %0d | Final out_val: %0d | done: %b | enable: %b", 
                         cycle_counter, $time, resetn, s_val, step, out_val_3, done_3, enable);
            end

            // Disable and reset for the next test
            #10 enable = 0;
            resetn = 0;
            #10;
        end
    endtask

    // Waveform dumping and simulation control
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_arithmetic_progression_generator);
        #1000 $finish;
    end

endmodule