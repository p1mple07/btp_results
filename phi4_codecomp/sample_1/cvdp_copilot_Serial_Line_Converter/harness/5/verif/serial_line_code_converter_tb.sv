`timescale 1ns/1ps

module serial_line_code_converter_tb;
    parameter CLK_DIV = 6; // Clock division parameter for timing

    // Testbench signals
    logic clk, reset_n, serial_in, serial_out;
    logic [2:0] mode;
    logic expected_out;

    // Define the array for feature names
    string features [7:0];

    // Tracking signals to mimic DUT behavior
    logic [3:0] tb_counter;
    logic tb_clk_pulse, tb_prev_serial_in, tb_alt_invert_state, tb_parity_out, tb_prev_value;

    // Instantiate the Device Under Test
    serial_line_code_converter #(CLK_DIV) dut (
        .clk(clk),
        .reset_n(reset_n),
        .serial_in(serial_in),
        .mode(mode),
        .serial_out(serial_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10ns
    end

    // Initialize signals and feature names
    initial begin
        tb_counter = 0;
        tb_clk_pulse = 0;
        tb_prev_serial_in = 0;
        tb_prev_value = 0;
        tb_alt_invert_state = 0;
        tb_parity_out = 0;
        reset_n = 0;
        serial_in = 0;
        mode = 3'b000;

        // Initialize feature names
        features[0] = "NRZ";
        features[1] = "RZ";
        features[2] = "Differential";
        features[3] = "Inverted NRZ";
        features[4] = "Alternate Inversion";
        features[5] = "Parity-Added";
        features[6] = "Scrambled NRZ";
        features[7] = "Edge-Triggered NRZ";

        // Apply reset
        @(negedge clk) reset_n = 1;
        @(posedge clk);
    end

    // Logic to mimic DUT's clock division and pulse generation
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tb_counter <= 0;
            tb_clk_pulse <= 0;
        end else if (tb_counter == CLK_DIV - 1) begin
            tb_counter <= 0;
            tb_clk_pulse <= 1;
        end else begin
            tb_counter <= tb_counter + 1;
            tb_clk_pulse <= 0;
        end
    end

    // Logic to update previous serial input state
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tb_prev_value <= 0;
            tb_prev_serial_in <= 0;
        end else begin
            tb_prev_value <= serial_in;
            tb_prev_serial_in <= tb_prev_value;
        end
    end

    // Logic for alternate inversion and parity bit calculation
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tb_alt_invert_state <= 0;
        end else begin
            tb_alt_invert_state <= ~tb_alt_invert_state;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tb_parity_out <= 0;
        end else begin
            tb_parity_out <= tb_parity_out ^ serial_in; // Update parity bit with serial input
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            expected_out = 0;
        end else begin
            case (mode)
                3'b000: expected_out = serial_in; // NRZ
                3'b001: expected_out = serial_in & tb_clk_pulse; // RZ
                3'b010: expected_out = serial_in ^ tb_prev_serial_in; // Differential
                3'b011: expected_out = ~serial_in; // Inverted NRZ
                3'b100: expected_out = tb_alt_invert_state ? ~serial_in : serial_in; // Alternate Inversion
                3'b101: expected_out = tb_parity_out ^ serial_in; // Parity-Added
                3'b110: expected_out = serial_in ^ tb_counter[0]; // Scrambled NRZ
                3'b111: expected_out = serial_in & ~tb_prev_serial_in; // Edge-Triggered NRZ
                default: expected_out = 0;
            endcase
        end
    end

    function string get_feature_name(input logic [2:0] mode);
        if (!reset_n) begin
            get_feature_name = "Reset";
        end else begin
            case (mode)
                3'b000: get_feature_name = "NRZ";
                3'b001: get_feature_name = "RZ";
                3'b010: get_feature_name = "Differential";
                3'b011: get_feature_name = "Inverted NRZ";
                3'b100: get_feature_name = "Alternate Inversion";
                3'b101: get_feature_name = "Parity-Added";
                3'b110: get_feature_name = "Scrambled NRZ";
                3'b111: get_feature_name = "Edge-Triggered NRZ";
                default: get_feature_name = "Unknown Mode";
            endcase
        end
    endfunction

    function void check_output(input logic expected, input string feature, input integer iteration);
        if (serial_out !== expected) begin
            $display("ERROR: %s failed in iteration %d. Expected: %b, Got: %b at time %t", 
                     feature, iteration, expected, serial_out, $time);
        end else begin
            $display("PASS: %s passed in iteration %d at time %t", 
                     feature, iteration, $time);
        end
    endfunction

    initial begin
        for (int m = 0; m < 8; m++) begin
            @(negedge clk);
            mode = m;
            $display("\nTesting %s Encoding...", get_feature_name(mode));
            @(posedge clk); // Wait one cycle after mode change

            for (int i = 0; i < 9; i++) begin
                @(negedge clk);
                serial_in = $random;
                @(posedge clk);
                check_output(expected_out, get_feature_name(mode), i);
            end
            #50;
        end

        $display("\nAll tests completed.");
        #100;
        $finish;
    end
    // Generate VCD waveform file (optional)
    initial begin
        $dumpfile("serial_line_code_converter.vcd");
        $dumpvars(0, serial_line_code_converter_tb);
    end
endmodule