module SetBitStreamCalculator #(
    parameter p_max_set_bit_count_width = 8
)(
    input  wire i_clk,
    input  wire i_ready,
    input  wire i_bit_in,
    input  wire i_rst_n,
    output reg  [p_max_set_bit_count_width-1:0] o_set_bit_count
);

    // Maximum count value based on parameter
    localparam max_count = (1 << p_max_set_bit_count_width) - 1;

    // Register to hold previous value of i_ready for edge detection
    reg ready_prev;
    // Flag to indicate that the first bit after i_ready assertion should be ignored
    reg ignore_next_bit;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_set_bit_count   <= 0;
            ignore_next_bit   <= 0;
            ready_prev        <= 0;
        end else begin
            // Detect rising edge of i_ready
            if (i_ready && !ready_prev) begin
                // When i_ready goes high, reset count and set flag to ignore the next bit
                o_set_bit_count   <= 0;
                ignore_next_bit   <= 1;
            end
            // If still in the first cycle after ready assertion, clear the ignore flag
            else if (i_ready && ignore_next_bit) begin
                ignore_next_bit   <= 0;
            end
            // Count bits only when i_ready is high and the ignore flag is not set
            else if (i_ready) begin
                if (i_bit_in) begin
                    if (o_set_bit_count == max_count) begin
                        // Saturate: do not increment further
                    end else begin
                        o_set_bit_count <= o_set_bit_count + 1;
                    end
                end
            end
            // Update the previous ready value at the end of the cycle
            ready_prev <= i_ready;
        end
    end

endmodule

// File: verif/SetBitStreamCalculator_tb.v
`timescale 1ns/1ps
module SetBitStreamCalculator_tb;

    // Clock period definition (50 MHz clock => 20 ns period)
    localparam CLK_PERIOD = 20;
    
    // Testbench signals
    reg clk;
    reg ready;
    reg bit_in;
    reg rst_n;
    
    // DUT instance for default parameter (p_max_set_bit_count_width = 8)
    wire [7:0] count_default;
    // DUT instance for saturation test (p_max_set_bit_count_width = 4)
    wire [3:0] count_sat;
    
    // Instantiate the DUT for default parameter
    SetBitStreamCalculator #(
        .p_max_set_bit_count_width(8)
    ) dut_default (
        .i_clk(clk),
        .i_ready(ready),
        .i_bit_in(bit_in),
        .i_rst_n(rst_n),
        .o_set_bit_count(count_default)
    );
    
    // Instantiate the DUT for saturation test with parameter override
    SetBitStreamCalculator #(
        .p_max_set_bit_count_width(4)
    ) dut_saturation (
        .i_clk(clk),
        .i_ready(ready),
        .i_bit_in(bit_in),
        .i_rst_n(rst_n),
        .o_set_bit_count(count_sat)
    );
    
    // Clock generation process
    initial begin
        clk = 0;
        forever # (CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test stimulus process
    initial begin
        // Initialize signals
        rst_n = 0;
        ready = 0;
        bit_in = 0;
        
        // Apply asynchronous reset for a few cycles
        #40;
        rst_n = 1;
        
        // ---------------------------------------------------------------
        // Scenario 1: Counting set bits with default p_max_set_bit_count_width = 8
        // According to the specification, the first bit after i_ready assertion is ignored.
        // For the test, we apply the following sequence when ready is asserted:
        //   i_bit_in: 1, 0, 1, 1
        // Expected behavior (per specification): The first bit (1) is ignored, then count increments for the two 1's.
        // (Note: The example scenario mentioned an output of 3, but here we follow the specification.)
        $display("Scenario 1: Counting set bits (p_max_set_bit_count_width = 8)");
        ready = 1;
        #20; // Wait for a clock edge after ready assertion
        bit_in = 1;  // This bit will be ignored
        #20;
        bit_in = 0;
        #20;
        bit_in = 1;
        #20;
        bit_in = 1;
        #20;
        $display("After Scenario 1, count_default = %0d (expected 2 based on spec, example said 3)", count_default);
        
        // Wait before next scenario
        #40;
        
        // ---------------------------------------------------------------
        // Scenario 2: Reset Behavior
        $display("Scenario 2: Reset Behavior");
        // Start counting with ready asserted
        ready = 1;
        #20;
        bit_in = 1;
        #20;
        bit_in = 1;
        #20;
        // Assert asynchronous reset while counting
        rst_n = 0;
        #20;
        rst_n = 1;
        #20;
        $display("After reset, count_default should be 0: %0d", count_default);
        
        // Wait before next scenario
        #40;
        
        // ---------------------------------------------------------------
        // Scenario 3: Saturation at maximum count for p_max_set_bit_count_width = 4
        $display("Scenario 3: Saturation Test (p_max_set_bit_count_width = 4, max count = 15)");
        // For the saturation test, we use the dut_saturation instance.
        // Send 16 consecutive 1's while ready is high.
        ready = 1;
        #20;
        repeat (16) begin
            bit_in = 1;
            #20;
        end
        $display("After 16 ones, count_sat should be 15 (saturated): %0d", count_sat);
        
        // Deassert ready to stop counting
        ready = 0;
        #40;
        
        $display("Testbench finished.");
        $finish;
    end

endmodule