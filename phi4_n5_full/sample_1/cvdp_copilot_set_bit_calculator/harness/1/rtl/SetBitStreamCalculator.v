module SetBitStreamCalculator #(
  parameter p_max_set_bit_count_width = 8
)(
  input  wire                      i_clk,
  input  wire                      i_rst_n,    // Active-low asynchronous reset
  input  wire                      i_ready,
  input  wire                      i_bit_in,
  output reg [p_max_set_bit_count_width-1:0] o_set_bit_count
);

  // Calculate maximum count value (saturation limit)
  localparam MAX_COUNT = (2 ** p_max_set_bit_count_width) - 1;

  // Registers to detect the rising edge of i_ready and to ignore the first bit
  reg ready_prev;
  reg first_bit;

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_set_bit_count <= 0;
      ready_prev      <= 0;
      first_bit       <= 1;  // Ensure first bit is ignored after reset
    end
    else begin
      // Detect rising edge of i_ready: transition from 0 to 1
      if (i_ready && !ready_prev) begin
        o_set_bit_count <= 0;
        first_bit       <= 1;  // Reset flag to ignore the first bit after ready assertion
      end
      else begin
        if (i_ready) begin
          if (first_bit) begin
            // Ignore the first bit after ready assertion
            first_bit <= 0;
          end
          else begin
            // Count only when i_ready is high and first_bit has been cleared
            if (o_set_bit_count == MAX_COUNT) begin
              // Saturated: do not increment further
              o_set_bit_count <= o_set_bit_count;
            end
            else if (i_bit_in)
              o_set_bit_count <= o_set_bit_count + 1;
            else
              o_set_bit_count <= o_set_bit_count;
          end
        end
      end
      ready_prev <= i_ready;
    end
  end

endmodule


// File: verif/SetBitStreamCalculator_tb.v
`timescale 1ns/1ps
module SetBitStreamCalculator_tb;

  // Default parameter for the DUT instantiation (p_max_set_bit_count_width = 8)
  parameter p_max_set_bit_count_width = 8;

  reg                      clk;
  reg                      rst_n;
  reg                      ready;
  reg                      bit_in;
  wire [p_max_set_bit_count_width-1:0] set_bit_count;

  // Instantiate the DUT with default parameter
  SetBitStreamCalculator #(
    .p_max_set_bit_count_width(p_max_set_bit_count_width)
  ) dut (
    .i_clk          (clk),
    .i_rst_n        (rst_n),
    .i_ready        (ready),
    .i_bit_in       (bit_in),
    .o_set_bit_count(set_bit_count)
  );

  // Clock generation: 50 MHz clock (period = 20 ns)
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  initial begin
    // Initialize signals
    rst_n = 0;
    ready = 0;
    bit_in = 0;

    // Apply asynchronous reset
    #25;
    rst_n = 1;
    #25;

    // ------------------------------------------------------------------
    // Scenario 1: Counting set bits with default p_max_set_bit_count_width = 8
    // i_ready = 1, i_bit_in transitions: 1, 0, 1, 1
    // Note: The first bit after ready assertion is ignored.
    // Expected: Count should be 3 (only the 2nd, 3rd, and 4th bits are counted)
    // ------------------------------------------------------------------
    ready = 1;
    #20; // Wait for a clock edge after ready assertion
    bit_in = 1; // First bit (ignored)
    #20;
    bit_in = 0;
    #20;
    bit_in = 1;
    #20;
    bit_in = 1;
    #20;
    $display("Scenario 1: Expected set_bit_count = 3, Actual = %0d", set_bit_count);

    // Deassert ready to hold the count, then reassert ready to continue counting
    ready = 0;
    #40;
    ready = 1;
    bit_in = 1;  // This bit will be counted (since first_bit is cleared)
    #20;
    $display("After reasserting ready and one bit: Expected set_bit_count = 4, Actual = %0d", set_bit_count);

    // ------------------------------------------------------------------
    // Scenario 2: Asynchronous Reset Behavior
    // Assert asynchronous reset (rst_n low) while counting.
    // Expected: o_set_bit_count resets immediately to 0.
    // ------------------------------------------------------------------
    rst_n = 0;
    #20;
    rst_n = 1;
    #20;
    $display("After asynchronous reset: Expected set_bit_count = 0, Actual = %0d", set_bit_count);

    // ------------------------------------------------------------------
    // Scenario 3: Saturation Test
    // Use a DUT instance with p_max_set_bit_count_width = 4 (max count = 15)
    // Drive 16 consecutive 1's. The count should saturate at 15.
    // ------------------------------------------------------------------
    // Declare a new wire for the saturation DUT
    wire [3:0] sat_set_bit_count;

    // Instantiate the saturation DUT
    SetBitStreamCalculator #(
      .p_max_set_bit_count_width(4)
    ) sat_dut (
      .i_clk          (clk),
      .i_rst_n        (rst_n),
      .i_ready        (ready),
      .i_bit_in       (bit_in),
      .o_set_bit_count(sat_set_bit_count)
    );

    // Prepare for saturation test
    ready = 1;
    #20;
    // Send 16 consecutive 1's
    for (int i = 0; i < 16; i++) begin
      bit_in = 1;
      #20;
    end
    $display("Saturation Test: Expected sat_set_bit_count = 15, Actual = %0d", sat_set_bit_count);

    $finish;
  end

endmodule