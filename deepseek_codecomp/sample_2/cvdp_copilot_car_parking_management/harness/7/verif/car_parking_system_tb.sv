`timescale 1ns / 1ps

module car_parking_system_tb;

    // Parameters
    parameter TOTAL_SPACES = 12;

    // DUT Inputs
    reg clk;
    reg reset;
    reg vehicle_entry_sensor;
    reg vehicle_exit_sensor;

    // DUT Outputs
    wire [$clog2(TOTAL_SPACES)-1:0] available_spaces;
    wire [$clog2(TOTAL_SPACES)-1:0] count_car;
    wire led_status;
    wire [6:0] seven_seg_display_available_tens;
    wire [6:0] seven_seg_display_available_units;
    wire [6:0] seven_seg_display_count_tens;
    wire [6:0] seven_seg_display_count_units;

    // Instantiate the DUT
    car_parking_system #(
        .TOTAL_SPACES(TOTAL_SPACES)
    ) dut (
        .clk(clk),
        .reset(reset),
        .vehicle_entry_sensor(vehicle_entry_sensor),
        .vehicle_exit_sensor(vehicle_exit_sensor),
        .available_spaces(available_spaces),
        .count_car(count_car),
        .led_status(led_status),
        .seven_seg_display_available_tens(seven_seg_display_available_tens),
        .seven_seg_display_available_units(seven_seg_display_available_units),
        .seven_seg_display_count_tens(seven_seg_display_count_tens),
        .seven_seg_display_count_units(seven_seg_display_count_units)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Task: Apply reset
    task apply_reset;
        begin
            reset = 1;
            #10; // Hold reset for 10ns
            reset = 0;
            #10; // Wait for reset release
        end
    endtask

    // Task: Simulate vehicle entry
    task simulate_entry;
        begin
            vehicle_entry_sensor = 1;
            #10; // Hold signal for 10ns
            vehicle_entry_sensor = 0;
        end
    endtask

    // Task: Simulate vehicle exit
    task simulate_exit;
        begin
            vehicle_exit_sensor = 1;
            #10; // Hold signal for 10ns
            vehicle_exit_sensor = 0;
        end
    endtask

    // Function: Seven-segment encoding
    function [6:0] seven_segment_encoding;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seven_segment_encoding = 7'b1111110;
                4'd1: seven_segment_encoding = 7'b0110000;
                4'd2: seven_segment_encoding = 7'b1101101;
                4'd3: seven_segment_encoding = 7'b1111001;
                4'd4: seven_segment_encoding = 7'b0110011;
                4'd5: seven_segment_encoding = 7'b1011011;
                4'd6: seven_segment_encoding = 7'b1011111;
                4'd7: seven_segment_encoding = 7'b1110000;
                4'd8: seven_segment_encoding = 7'b1111111;
                4'd9: seven_segment_encoding = 7'b1111011;
                default: seven_segment_encoding = 7'b0000000;
            endcase
        end
    endfunction

    integer available_tens;
    integer available_units;
    integer count_tens;
    integer count_units;

    // Task: Comprehensive Checker
    task check_outputs;
        input integer expected_available_spaces;
        input integer expected_count_car;
        input integer expected_led_status;
        begin
            // Check available spaces
            if (available_spaces !== expected_available_spaces) begin
                $display("ERROR: Available spaces mismatch! Expected: %0d, Got: %0d", expected_available_spaces, available_spaces);
            end

            // Check count cars
            if (count_car !== expected_count_car) begin
                $display("ERROR: Count car mismatch! Expected: %0d, Got: %0d", expected_count_car, count_car);
            end

            // Check LED status
            if (led_status !== expected_led_status) begin
                $display("ERROR: LED status mismatch! Expected: %b, Got: %b", expected_led_status, led_status);
            end

            // Calculate expected tens and units digits
            available_tens = expected_available_spaces / 10;
            available_units = expected_available_spaces % 10;
            count_tens = expected_count_car / 10;
            count_units = expected_count_car % 10;

            // Check seven-segment values for available spaces
            if (seven_seg_display_available_tens !== seven_segment_encoding(available_tens)) begin
                $display("ERROR: Seven-segment available_tens mismatch! Expected: %b, Got: %b", seven_segment_encoding(available_tens), seven_seg_display_available_tens);
            end
            if (seven_seg_display_available_units !== seven_segment_encoding(available_units)) begin
                $display("ERROR: Seven-segment available_units mismatch! Expected: %b, Got: %b", seven_segment_encoding(available_units), seven_seg_display_available_units);
            end

            // Check seven-segment values for count cars
            if (seven_seg_display_count_tens !== seven_segment_encoding(count_tens)) begin
                $display("ERROR: Seven-segment count_tens mismatch! Expected: %b, Got: %b", seven_segment_encoding(count_tens), seven_seg_display_count_tens);
            end
            if (seven_seg_display_count_units !== seven_segment_encoding(count_units)) begin
                $display("ERROR: Seven-segment count_units mismatch! Expected: %b, Got: %b", seven_segment_encoding(count_units), seven_seg_display_count_units);
            end
        end
    endtask


    // Testbench logic
    initial begin
        // Initialize inputs
        reset = 0;
        vehicle_entry_sensor = 0;
        vehicle_exit_sensor = 0;

        // Apply reset
        apply_reset;

        // Test 1: Vehicle entry
        $display("Test 1: Simulating vehicle entry...");
        simulate_entry;
        #20; // Wait for state update
        check_outputs(TOTAL_SPACES - 1, 1, 1);
        $display("Available spaces: %0d, Count car: %0d, LED Status: %0b", available_spaces, count_car, led_status);

        // Test 2: Vehicle exit
        $display("Test 2: Simulating vehicle exit...");
        simulate_exit;
        #20; // Wait for state update
        check_outputs(TOTAL_SPACES, 0, 1);
        $display("Available spaces: %0d, Count car: %0d, LED Status: %0b", available_spaces, count_car, led_status);

        // Test 3: Parking full
        $display("Test 3: Simulating parking full...");
        repeat (TOTAL_SPACES) begin
            simulate_entry;
            #20;
        end
        #20; // Wait for state update
        check_outputs(0, TOTAL_SPACES, 0);
        $display("Available spaces: %0d, Count car: %0d, LED Status: %0b", available_spaces, count_car, led_status);

        // Test 4: Simulate reset
        $display("Test 4: Applying reset...");
        apply_reset;
        #20; // Wait for state update
        check_outputs(TOTAL_SPACES, 0, 1);
        $display("Available spaces: %0d, Count car: %0d, LED Status: %0b", available_spaces, count_car, led_status);


        // End simulation
        $display("All tests completed successfully.");
        $finish;
    end

endmodule