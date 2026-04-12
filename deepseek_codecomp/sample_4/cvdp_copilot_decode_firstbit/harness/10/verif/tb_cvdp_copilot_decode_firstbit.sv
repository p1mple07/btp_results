`timescale 1ns/1ps

module tb_cvdp_copilot_decode_firstbit;

    // Parameters
    parameter integer InWidth_g = 32;
    parameter integer InReg_g = 1;        // Enable input register
    parameter integer OutReg_g = 1;       // Enable output register
    parameter integer PlRegs_g = 1;       // Number of pipeline stages

    // Clock period (adjust as needed)
    localparam CLK_PERIOD = 10;

    // Signals
    reg Clk;
    reg Rst;
    reg [InWidth_g-1:0] In_Data;
    reg In_Valid;

    // Outputs for binary encoding
    wire [InWidth_g-1:0] Out_FirstBit_Binary;
    wire Out_Found_Binary;
    wire Out_Valid_Binary;

    // Outputs for one-hot encoding
    wire [InWidth_g-1:0] Out_FirstBit_OneHot;
    wire Out_Found_OneHot;
    wire Out_Valid_OneHot;

    // Instantiate the Device Under Test (DUT) with binary output
    cvdp_copilot_decode_firstbit #(
        .InWidth_g(InWidth_g),
        .InReg_g(InReg_g),
        .OutReg_g(OutReg_g),
        .PlRegs_g(PlRegs_g),
        .OutputFormat_g(0)  // Binary encoding
    ) dut_binary (
        .Clk(Clk),
        .Rst(Rst),
        .In_Data(In_Data),
        .In_Valid(In_Valid),
        .Out_FirstBit(Out_FirstBit_Binary),
        .Out_Found(Out_Found_Binary),
        .Out_Valid(Out_Valid_Binary)
    );

    // Instantiate the Device Under Test (DUT) with one-hot output
    cvdp_copilot_decode_firstbit #(
        .InWidth_g(InWidth_g),
        .InReg_g(InReg_g),
        .OutReg_g(OutReg_g),
        .PlRegs_g(PlRegs_g),
        .OutputFormat_g(1)  // One-hot encoding
    ) dut_onehot (
        .Clk(Clk),
        .Rst(Rst),
        .In_Data(In_Data),
        .In_Valid(In_Valid),
        .Out_FirstBit(Out_FirstBit_OneHot),
        .Out_Found(Out_Found_OneHot),
        .Out_Valid(Out_Valid_OneHot)
    );

    // Clock generation
    initial begin
        Clk = 0;
        forever #(CLK_PERIOD/2) Clk = ~Clk;
    end

    // Test stimulus
    initial begin
        // VCD Dumping
        $dumpfile("tb_cvdp_copilot_decode_firstbit.vcd"); // Specify the VCD file name
        $dumpvars(0, tb_cvdp_copilot_decode_firstbit);    // Dump all variables in the testbench        

        // Initialize inputs
        Rst = 1;
        In_Data = {InWidth_g{1'b0}};
        In_Valid = 0;

        // Wait for reset
        #(CLK_PERIOD*5);
        Rst = 0;

        // Apply test vectors
        apply_test_vector(32'h00000000); // No bits set
        apply_test_vector(32'h00000001); // First bit set
        apply_test_vector(32'h00000002); // Second bit set
        apply_test_vector(32'h80000000); // Last bit set
        apply_test_vector(32'h00010000); // Middle bit set
        apply_test_vector(32'hFFFFFFFF); // All bits set
        apply_test_vector(32'hFFFFFFFE); // All but first bit set
        apply_test_vector(32'h7FFFFFFF); // All but last bit set
        apply_test_vector(32'h00008000); // Random bit set
        apply_test_vector(32'h00000008); // Another random bit set
        // Adjusted to 32-bit width
        apply_test_vector(32'h00012000); // Another random bit set

        // Finish simulation after some time
        #(CLK_PERIOD*20);
        $finish;
    end

    // Task to apply a test vector
    task apply_test_vector(input [InWidth_g-1:0] data_in);
        integer expected_index;
        reg [InWidth_g-1:0] expected_onehot;
        begin
            // Apply input data
            @(negedge Clk);
            In_Data = data_in;
            In_Valid = 1;

            @(negedge Clk);
            In_Valid = 0;

            // Wait for the output to become valid, accounting for pipeline latency
            wait (Out_Valid_Binary && Out_Valid_OneHot);

            // Calculate expected index and one-hot encoding
            expected_index = find_first_set_bit(data_in);
            expected_onehot = one_hot_encode(expected_index);

            // Display and check the result for binary encoding
            if (Out_Found_Binary) begin
                $display("Binary Encoding - Time %t: Input = %h, Expected Index = %d, DUT Output = %d",
                         $time, data_in, expected_index, Out_FirstBit_Binary[($clog2(InWidth_g)-1):0]);
                if (Out_FirstBit_Binary[($clog2(InWidth_g)-1):0] != expected_index) begin
                    $display("ERROR: Mismatch in binary first set bit index!");
                end
            end else begin
                $display("Binary Encoding - Time %t: Input = %h, No set bits found (as expected)", $time, data_in);
                if (expected_index != -1) begin
                    $display("ERROR: DUT did not find the first set bit when it should have!");
                end
            end

            // Display and check the result for one-hot encoding
            if (Out_Found_OneHot) begin
                $display("One-Hot Encoding - Time %t: Input = %h, Expected One-Hot = %h, DUT Output = %h",
                         $time, data_in, expected_onehot, Out_FirstBit_OneHot);
                if (Out_FirstBit_OneHot != expected_onehot) begin
                    $display("ERROR: Mismatch in one-hot first set bit!");
                end
            end else begin
                $display("One-Hot Encoding - Time %t: Input = %h, No set bits found (as expected)", $time, data_in);
                if (expected_index != -1) begin
                    $display("ERROR: DUT did not find the first set bit when it should have!");
                end
            end

            // Wait before applying next test vector
            #(CLK_PERIOD*2);
        end
    endtask

    // Function to find the expected first set bit index
    function integer find_first_set_bit(input [InWidth_g-1:0] data_in);
        integer idx;
        reg found;
        begin
            find_first_set_bit = -1; // Default to -1 if no bits are set
            found = 0;
            for (idx = 0; idx < InWidth_g; idx = idx + 1) begin
                if (!found && data_in[idx]) begin
                    find_first_set_bit = idx;
                    found = 1; // Set the flag to indicate the first set bit is found
                end
            end
        end
    endfunction

    // Function to generate expected one-hot encoding
    function [InWidth_g-1:0] one_hot_encode(input integer index);
        begin
            if (index >= 0 && index < InWidth_g) begin
                one_hot_encode = {InWidth_g{1'b0}};
                one_hot_encode[index] = 1'b1;
            end else begin
                one_hot_encode = {InWidth_g{1'b0}};
            end
        end
    endfunction

endmodule