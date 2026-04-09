module SetBitStreamCalculator #(
    parameter p_max_set_bit_count_width = 8
)(
    input  wire i_clk,
    input  wire i_rst_n,         // asynchronous active-low reset
    input  wire i_bit_in,        // single-bit input stream
    input  wire i_ready,         // when high, enables counting; transition from low to high resets count
    output reg  [p_max_set_bit_count_width-1:0] o_set_bit_count
);

    // Maximum count value based on parameter width
    localparam integer MAX_COUNT = (1 << p_max_set_bit_count_width) - 1;

    // Register to detect transition from low to high on i_ready
    reg ready_prev;
    // Flag to indicate that the first bit after i_ready transition should be ignored
    reg first_cycle;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_set_bit_count <= 0;
            ready_prev      <= 0;
            first_cycle     <= 0;
        end else begin
            // Update previous ready value
            ready_prev <= i_ready;
            
            // Detect transition from low to high: reset count and set first_cycle flag
            if (i_ready && !ready_prev) begin
                o_set_bit_count <= 0;
                first_cycle     <= 1;
            end 
            // When i_ready is high, process the bit stream
            else if (i_ready) begin
                if (first_cycle) begin
                    // First bit after transition: ignore it and clear the flag
                    first_cycle <= 0;
                end 
                else begin
                    // Count normally: increment count if i_bit_in is 1 and not saturated
                    if (i_bit_in) begin
                        if (o_set_bit_count == MAX_COUNT)
                            o_set_bit_count <= MAX_COUNT; // saturate
                        else
                            o_set_bit_count <= o_set_bit_count + 1;
                    end
                end
            end
            // When i_ready is low, count holds (no update)
        end
    end

endmodule


// File: verif/SetBitStreamCalculator_tb.v
`timescale 1ns/1ps
module SetBitStreamCalculator_tb;

  // Clock parameters
  parameter CLK_PERIOD = 20;  // 50 MHz clock

  reg clk;
  reg rst_n;
  reg bit_in;
  reg ready;

  // Wires for the instance with default parameter (p_max_set_bit_count_width = 8)
  wire [7:0] set_bit_count_8;
  // Wires for the instance with parameter 4 (for saturation test)
  wire [3:0] set_bit_count_4;

  // Instantiate module with default parameter (8-bit count)
  SetBitStreamCalculator #(
      .p_max_set_bit_count_width(8)
  ) dut_8 (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_bit_in(bit_in),
      .i_ready(ready),
      .o_set_bit_count(set_bit_count_8)
  );

  // Instantiate module with parameter 4 (maximum count = 15)
  SetBitStreamCalculator #(
      .p_max_set_bit_count_width(4)
  ) dut_4 (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_bit_in(bit_in),
      .i_ready(ready),
      .o_set_bit_count(set_bit_count_4)
  );

  // Clock generation
  initial begin
      clk = 0;
      forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Testbench stimulus
  initial begin
      // Initialize signals
      rst_n = 0;
      ready = 0;
      bit_in = 0;
      # (CLK_PERIOD*2);
      rst_n = 1;  // Deassert asynchronous reset

      //--------------------------------------------------------------------------
      // Scenario 1: Counting set bits with p_max_set_bit_count_width = 8
      // Sequence: i_ready asserted; bit sequence: 1, 0, 1, 1.
      // The first bit after i_ready goes high is ignored.
      // Expected count: 3 (only the two 1's after the first bit are counted).
      //--------------------------------------------------------------------------

      $display("Scenario 1: Counting set bits with p_max_set_bit_count_width = 8");
      ready = 1;  // Assert i_ready to start counting
      # (CLK_PERIOD);
      bit_in = 1; // First bit (ignored)
      # (CLK_PERIOD);
      bit_in = 0;
      # (CLK_PERIOD);
      bit_in = 1;
      # (CLK_PERIOD);
      bit_in = 1;
      # (CLK_PERIOD*2);
      if (set_bit_count_8 == 3)
          $display("Scenario 1 Passed: o_set_bit_count_8 = %d", set_bit_count_8);
      else
          $display("Scenario 1 Failed: o_set_bit_count_8 = %d (expected 3)", set_bit_count_8);

      //--------------------------------------------------------------------------
      // Scenario 2: Reset Behavior
      // While counting, assert asynchronous reset (i_rst_n low) to reset the count.
      //--------------------------------------------------------------------------

      ready = 0;  // Deassert i_ready to hold the current count
      # (CLK_PERIOD*2);
      ready = 1;  // Assert i_ready again to resume counting
      $display("Scenario 2: Reset Behavior");
      bit_in = 1;
      # (CLK_PERIOD);
      rst_n = 0;  // Assert asynchronous reset (active low)
      # (CLK_PERIOD);
      rst_n = 1;  // Deassert reset
      # (CLK_PERIOD);
      if (set_bit_count_8 == 0)
          $display("Scenario 2 Passed: o_set_bit_count_8 reset to 0");
      else
          $display("Scenario 2 Failed: o_set_bit_count_8 = %d (expected 0)", set_bit_count_8);

      //--------------------------------------------------------------------------
      // Scenario 3: Saturation Test with p_max_set_bit_count_width = 4
      // Apply 16 consecutive 1's. The first bit is ignored, so 15 ones should be counted.
      // With saturation, the maximum count is 15.
      //--------------------------------------------------------------------------

      $display("Scenario 3: Saturation test with p_max_set_bit_count_width = 4");
      ready = 1;  // Assert i_ready to start counting in dut_4
      # (CLK_PERIOD);
      // Apply 16 consecutive 1's
      repeat (16) begin
          bit_in = 1;
          # (CLK_PERIOD);
      end
      # (CLK_PERIOD*2);
      if (set_bit_count_4 == 15)
          $display("Scenario 3 Passed: o_set_bit_count_4 = %d", set_bit_count_4);
      else
          $display("Scenario 3 Failed: o_set_bit_count_4 = %d (expected 15)", set_bit_count_4);

      $display("Testbench finished.");
      # (CLK_PERIOD*10);
      $finish;
  end

endmodule