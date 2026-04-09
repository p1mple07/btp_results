// Top level systolic array module
module systolic_array (
  // Description: A 2x2 systolic array for matrix multiplication using stationary processing elements.
  // Input/Output Pins:
  //   clock: Clock signal
  //   reset: Synchronous reset
  //   start: Start/Stop control
  //   done: Completion detection
  //   data_valid: Validity of incoming data
  //   weights_valid: Validity of incoming weights
  //   input_data: Input data vector [ DATA_WIDTH-1:0 ]
  //   weights: Weight vector [ DATA_WIDTH-1:0 ]
  //   output_result: Result vector [ DATA_WIDTH-1:0 ] 
)
  // Instantiate Processing Elements
  weight_stationary_pe pe_0_0,
                   pe_0_1,
                   pe_1_0,
                   pe_1_1;

  // Internal control signals
  reg clock_start = 1'b0;
  reg clockpe0 = 1'b0;
  reg clockpe1 = 1'b0;
  reg clockpe2 = 1'b0;
  reg clockpe3 = 1'b0;

  // Data routing
  wire input_data_00 -> pe_0_0.input_in;
  wire input_data_01 -> pe_0_1.input_in;
  wire input_data_10 -> pe_1_0.input_in;
  wire input_data_11 -> pe_1_1.input_in;

  wire pe_0_0.psum_out -> pe_0_1.psum_in;
  wire pe_0_0.psum_out -> pe_1_0.psum_in;
  wire pe_0_1.psum_out -> pe_1_1.psum_in;
  wire pe_1_0.psum_out -> pe_1_1.psum_in;

  wire pe_0_0.input_out -> pe_0_1.input_in;
  wire pe_0_0.input_out -> pe_1_0.input_in;

  wire pe_1_0.input_out -> pe_1_1.input_in;

  // Weight loading
  wire start_0_0 -> pe_0_0.load_weight;
  wire start_0_1 -> pe_0_1.load_weight;
  wire start_1_0 -> pe_1_0.load_weight;
  wire start_1_1 -> pe_1_1.load_weight;

  // Control signals
  wire done_0_0 -> done_0_1;
  wire done_0_1 -> done_1_1;
  wire done_1_0 -> done_1_1;

  // Inputs
  wire [{DATA_WIDTH}{1'b0}] input_data;
  wire [DATA_WIDTH-1:0] weights;
  wire [DATA_WIDTH-1:0] data_valid;
  wire [DATA_WIDTH-1:0] weights_valid;

  // Outputs
  reg [DATA_WIDTH-1:0] output_result0, output_result1;

  // Additional control logic
  always @posedge clock or posedge reset) begin
    if (reset) begin
      clock_start = 1'b1;
      clockpe0 = 1'b1;
      clockpe1 = 1'b1;
      clockpe2 = 1'b1;
      clockpe3 = 1'b1;
      start_0_0 = 1'b0;
      start_0_1 = 1'b0;
      start_1_0 = 1'b0;
      start_1_1 = 1'b0;
    end else begin
      if (data_valid && weights_valid) begin
        clock_start = 1'b0;
        if (!clockpe0 || !clockpe1 || !clockpe2 || !clockpe3) begin
          clockpe0 = 1'b1;
          clockpe1 = 1'b1;
          clockpe2 = 1'b1;
          clockpe3 = 1'b1;
        end
      end
    end
  end

  // Synchronization and completion detection
  always @posedge clock) begin
    if (start) begin
      start_0_0 = 1'b1;
      start_0_1 = 1'b1;
      start_1_0 = 1'b1;
      start_1_1 = 1'b1;
      
      // Wait for first completion
      if (done_0_0) begin
        done_0_1 = 1'b1;
        done_1_0 = 1'b1;
        done_1_1 = 1'b1;
      end
      
      // Finalize results
      output_result0 = pe_0_0.output;
      output_result1 = pe_1_1.output;
      
      // Assert done after computation completes
      if (done_1_1) begin
        $display("All computations complete.");
        highbit(dones[$threadID]); // Consume final bit
      end
    end
    else
      start_0_0 = 1'b0;
      start_0_1 = 1'b0;
      start_1_0 = 1'b0;
      start_1_1 = 1'b0;
  end