Module: SetBitStreamCalculator
// Description: Counts the number of 1 bits received on i_bit_in when i_ready is high.
//              The count is updated on the rising edge of i_clk. When i_ready transitions
//              from low to high, the count resets to 0 and the first bit is ignored.
//              The count saturates at (2^p_max_set_bit_count_width - 1). An asynchronous
//              active-low reset (i_rst_n) resets the count immediately.
module SetBitStreamCalculator #(
    parameter p_max_set_bit_count_width = 8
)(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_ready,
    input wire i_bit_in,
    output reg [p_max_set_bit_count_width-1:0] o_set_bit_count
);

    // Maximum count value based on parameter width
    localparam max_count = (1 << p_max_set_bit_count_width) - 1;
    
    // Register to indicate that the first bit after i_ready goes high should be ignored
    reg ignore_next;
    // Register to store the previous value of i_ready for edge detection
    reg ready_prev;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_set_bit_count <= 0;
            ignore_next     <= 1'b0;
            ready_prev      <= 1'b0;
        end else begin
            // Detect rising edge of i_ready (transition from 0 to 1)
            if (i_ready && !ready_prev) begin
                o_set_bit_count <= 0;
                ignore_next     <= 1'b1;
            end else if (i_ready) begin
                if (ignore_next) begin
                    // First bit after ready goes high is ignored
                    ignore_next <= 1'b0;
                end else begin
                    // If i_bit_in is 1 and not saturated, increment the count
                    if (i_bit_in) begin
                        if (o_set_bit_count < max_count)
                            o_set_bit_count <= o_set_bit_count + 1;
                        // Else, remain saturated
                    end
                end
            end
            // Update ready_prev for next cycle
            ready_prev <= i_ready;
        end
    end

endmodule

//------------------------------------------------------------------------------
// Testbench for SetBitStreamCalculator
//------------------------------------------------------------------------------
module SetBitStreamCalculator_tb;

    // Clock period: 50 MHz (20 ns period)
    localparam CLK_PERIOD = 20;

    // Signals for default DUT instance (p_max_set_bit_count_width = 8)
    reg clk;
    reg rst_n;
    reg ready;
    reg bit_in;
    wire [7:0] set_bit_count;

    // Instantiate the default DUT
    SetBitStreamCalculator dut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_ready(ready),
        .i_bit_in(bit_in),
        .o_set_bit_count(set_bit_count)
    );

    // Signals for saturation DUT instance (p_max_set_bit_count_width = 4)
    reg sat_ready;
    reg sat_bit_in;
    wire [3:0] sat_set_bit_count;

    // Instantiate the saturation DUT
    SetBitStreamCalculator #(
        .p_max_set_bit_count_width(4)
    ) dut_sat (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_ready(sat_ready),
        .i_bit_in(sat_bit_in),
        .o_set_bit_count(sat_set_bit_count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever # (CLK_PERIOD/2) clk = ~clk;
    end

    // Initialize saturation signals
    initial begin
        sat_ready = 0;
        sat_bit_in = 0;
    end

    // Test stimulus
    initial begin
        // --- Default DUT Tests (p_max_set_bit_count_width = 8) ---

        // Initialize signals and assert asynchronous reset
        rst_n = 0;
        ready = 0;
        bit_in = 0;
        # (CLK_PERIOD*2);
        
        // Deassert reset
        rst_n = 1;
        # (CLK_PERIOD*2);

        // Scenario 1: Counting set bits.
        // When i_ready goes high, the first bit is ignored.
        // Test pattern: 1, 0, 1, 1  -> Expected count = 3
        ready = 1;
        # (CLK_PERIOD); // Rising edge: ready transition detected; count resets and first bit ignored
        bit_in = 1;      // Ignored (first bit after ready goes high)
        # (CLK_PERIOD);
        bit_in = 0;
        # (CLK_PERIOD);
        bit_in = 1;
        # (CLK_PERIOD);
        bit_in = 1;
        # (CLK_PERIOD*2);
        $display("Scenario 1: Expected set bit count = 3, Actual = %d", set_bit_count);

        // Scenario 2: Verify reset on reassertion of i_ready.
        // Deassert ready then reassert; first bit after reassertion is ignored.
        ready = 0;
        # (CLK_PERIOD*2);
        ready = 1;
        # (CLK_PERIOD); // Rising edge: ready transition detected; count resets and first bit ignored
        bit_in = 1;
        # (CLK_PERIOD);
        $display("After reassert ready: Expected set bit count = 1, Actual = %d", set_bit_count);

        // Scenario 3: Asynchronous reset during counting.
        ready = 1;
        bit_in = 1;
        # (CLK_PERIOD);
        bit_in = 1;
        # (CLK_PERIOD);
        rst_n = 0; // Asynchronous reset asserted
        # (CLK_PERIOD);
        rst_n = 1;
        # (CLK_PERIOD*2);
        $display("After async reset: Expected set bit count = 0, Actual = %d", set_bit_count);

        // End default DUT tests.
        // Ensure default DUT inputs are inactive during saturation test.
        ready = 0;
        bit_in = 0;

        // Wait before starting saturation test
        # (CLK_PERIOD*2);

        // --- Saturation DUT Tests (p_max_set_bit_count_width = 4) ---

        // Scenario 4: Saturation test.
        // With a 4-bit width, max count = 15.
        // Send 16 consecutive 1's; first bit is ignored.
        rst_n = 1;
        sat_ready = 1;
        # (CLK_PERIOD); // Rising edge: ready transition detected; count resets and first bit ignored
        for (int i = 0; i < 16; i = i + 1) begin
            sat_bit_in = 1;
            # (CLK_PERIOD);
        end
        # (CLK_PERIOD*2);
        $display("Scenario 4: Expected set bit count = 15, Actual = %d", sat_set_bit_count);

        $finish;
    end

endmodule