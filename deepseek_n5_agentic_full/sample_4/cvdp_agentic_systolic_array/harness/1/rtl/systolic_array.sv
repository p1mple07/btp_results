module systolic_array (
  // Procedural block for clock generation
  parameter DATA_WIDTH = 8,
  parameter CLK_PERIOD = 20 // Adjusted period for four PE stages
)

  // Register for global clock control
  reg clock_systolic_array;
  always @posedge clock_systolic_array or posedge reset) begin
    if (reset) {
      clock_systolic_array = 1'b0;
    } else {
      clock_systolic_array = 1'b1;
    }
  end

  // Instantiate weight_stationary_pe modules
  module top_pe1;
    weight_stationary_pe #(
      DATA_WIDTH = DATA_WIDTH
    ) pe1 (
        input    wire              input_in1,
        input    wire              input_in2,
        input    wire              input_in3,
        input    wire              input_in4,
        input    wire [DATA_WIDTH-1:0] weight1,
        input    wire [DATA_WIDTH-1:0] weight2,
        input    wire [DATA_WIDTH-1:0] weight3,
        input    wire [DATA_WIDTH-1:0] weight4,
        output   reg [DATA_WIDTH-1:0] out1,
        output   reg [DATA_WIDTH-1:0] psum1
      );
  
    // Instantiate weight_stationary_pe modules
  module top_pe2;
    weight_stationary_pe #(
      DATA_WIDTH = DATA_WIDTH
    ) pe2 (
        input    wire              input_in1,
        input    wire              input_in2,
        input    wire              input_in3,
        input    wire              input_in4,
        input    wire [DATA_WIDTH-1:0] weight1,
        input    wire [DATA_WIDTH-1:0] weight2,
        input    wire [DATA_WIDTH-1:0] weight3,
        input    wire [DATA_WIDTH-1:0] weight4,
        output   reg [DATA_WIDTH-1:0] out2,
        output   reg [DATA_WIDTH-1:0] psum2
      );
  
    // Instantiate weight_stationary_pe modules
  module top_pe3;
    weight_stationary_pe #(
      DATA_WIDTH = DATA_WIDTH
    ) pe3 (
        input    wire              input_in1,
        input    wire              input_in2,
        input    wire              input_in3,
        input    wire              input_in4,
        input    wire [DATA_WIDTH-1:0] weight1,
        input    wire [DATA_WIDTH-1:0] weight2,
        input    wire [DATA_WIDTH-1:0] weight3,
        input    wire [DATA_WIDTH-1:0] weight4,
        output   reg [DATA_WIDTH-1:0] out3,
        output   reg [DATA_WIDTH-1:0] psum3
      );
  
    // Instantiate weight_stationary_pe modules
  module top_pe4;
    weight_stationary_pe #(
      DATA_WIDTH = DATA_WIDTH
    ) pe4 (
        input    wire              input_in1,
        input    wire              input_in2,
        input    wire              input_in3,
        input    wire              input_in4,
        input    wire [DATA_WIDTH-1:0] weight1,
        input    wire [DATA_WIDTH-1:0] weight2,
        input    wire [DATA_WIDTH-1:0] weight3,
        input    wire [DATA_WIDTH-1:0] weight4,
        output   reg [DATA_WIDTH-1:0] out4,
        output   reg [DATA_WIDTH-1:0] psum4
      );
  
  // Connections between PEs
  // Create a 2x2 grid of PEs
  // Connect PEs in first row: pe1, pe2
  pe1.input_in1 = pe2.input_in1;
  pe1.input_in2 = pe2.input_in2;
  pe1.input_in3 = pe2.input_in3;
  pe1.input_in4 = pe2.input_in4;

  // Connect PEs in second row: pe3, pe4
  pe3.input_in1 = pe4.input_in1;
  pe3.input_in2 = pe4.input_in2;
  pe3.input_in3 = pe4.input_in3;
  pe3.input_in4 = pe4.input_in4;

  // Connect vertical data paths
  pe1.psum_out <= pe3.psum_in;
  pe2.psum_out <= pe4.psum_in;

  // Clock generation
  reg clock_systolic_array;
  integer i;
  initial begin
    clock_systolic_array = 1'b0;
    #(2*CLK_PERIOD);
    clock_systolic_array = 1'b1;
    #(2*CLK_PERIOD);
  end

  // Input controls
  reg load_weights, start;
  reg valid1, valid2, valid3, valid4;

  // Data inputs
  reg [DATA_WIDTH-1:0] input_in1, input_in2, input_in3, input_in4;

  // Weight loads
  reg [DATA_WIDTH-1:0] weight1, weight2, weight3, weight4;

  // Outputs
  wire [DATA_WIDTH-1:0] y0, y1;

  // Connect external to internal inputs/outputs
  input_in1 <= input_in;
  input_in2 <= input_in;
  input_in3 <= input_in;
  input_in4 <= input_in;

  weight1 <= weight;
  weight2 <= weight;
  weight3 <= weight;
  weight4 <= weight;

  y0 <= pe1.out;
  y1 <= pe2.out;
  
  // Control logic
  always @posedge clock_systolic_array or posedge reset) begin
    if (reset) {
      clock_systolic_array <= 1'b0;
      load_weights <= 1'b0;
      start <= 1'b0;
      valid1 <= 1'b0;
      valid2 <= 1'b0;
      valid3 <= 1'b0;
      valid4 <= 1'b0;
    } else begin
      clock_systolic_array <= 1'b1;
      load_weights <= 1'b1;
      start <= 1'b1;
      
      if (valid1) begin
        pe1.load_weight <= 1'b1;
        valid1 <= 1'b0;
      end
      if (valid2) begin
        pe2.load_weight <= 1'b1;
        valid2 <= 1'b0;
      end
      if (valid3) begin
        pe3.load_weight <= 1'b1;
        valid3 <= 1'b0;
      end
      if (valid4) begin
        pe4.load_weight <= 1'b1;
        valid4 <= 1'b0;
      end
    end
  end
  
  // Verify completion
  always begin
    if (!clock_systolic_array && !reset) {
      // Capture results after full computation
      y0 <= pe1.out;
      y1 <= pe2.out;
    }
  end
  
endmodule