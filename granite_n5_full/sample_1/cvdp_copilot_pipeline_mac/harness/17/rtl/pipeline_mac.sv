module pipeline_mac #(
    parameter DWIDTH = 16,  // Bit width for multiplicand and multiplier
    parameter N      = 4    // Number of data points to accumulate over
) (
    clk,
    rstn,
    multiplicand,
    multiplier,
    valid_i,
    result,
    valid_out
);
  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  
  // Calculate DWIDTH_ACCUMULATOR to handle the result bit width to avoid overflow
  localparam DWIDTH_ACCUMULATOR = DWIDTH * $clog2(N) - 1;

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  input logic clk;                                // Clock signal
  input logic rstn;                               // Active low reset signal
  input logic [DWIDTH-1:0] multiplicand;          // Input multiplicand
  input logic [DWIDTH-1:0] multiplier;            // Input multiplier
  input logic valid_i;                            // Input valid signal
  output logic [DWIDTH_ACCUMULATOR-1:0] result;   // Accumulated result output
  output logic valid_out;                         // Output valid signal, indicates when result is ready

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;    // Register to store intermediate multiplication result
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;   // Register to store accumulated result
  logic [$clog2(N):0] counter;                       // Counter to track the number of accumulations
  logic [$clog2(N)-1:0] counter_reg;                // Register to hold the value of the counter
  logic count_rst, accumulator_rst;                  // Reset signals for counter and accumulator
  logic valid_out_s0,valid_out_s1,valid_out_s2;      // Intermediate Signals indicating that the valid output is ready
  logic valid_i_s1;                                  // Intermediate Signals indicating input valid signal
  // ----------------------------------------
  // - Procedural blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always_ff @(posedge clk or negedge rstn) begin
  
    if (!rstn) begin
      mult_result_reg <= 'x;
      valid_i_s1 <= 0;
    end else begin
      mult_result_reg <= {mult_result_reg[DWIDTH-2:0], multiplier[DWIDTH-1]};
      valid_i_s1 <= valid_i;
    end
    
  end

  // Stage 2 of the pipeline: Accumulation logic
  always_ff @(posedge clk or negedge rstn) begin
  
    if (!rstn) begin
      accumulation_reg <= 'x;
      counter_reg <= 'b0;
    end else begin
      accumulation_reg <= accumulation_reg + mult_result_reg;
      counter_reg <= counter_reg + 1'b1;
    end
    
  end

  // N-bit counter to track the number of accumulations
  always_ff @(posedge clk or negedge rstn) begin
  
    if (!rstn) begin
      counter <= 'b1;
    end else begin
      counter <= count_rst? 'b1 : (valid_i & rstn? (counter_reg + 'd1) : counter_reg); 
    end
    
  end

  // Register valid output for 2-stage pipeline
  always_ff @(posedge clk or negedge rstn) begin
  
    if (!rstn) begin
      valid_out_s0 <= 0;
      count_rst <= 0;
    end else begin
      valid_out_s0 <= (counter_reg == N-1);   
      count_rst <= valid_out_s1;                
    end
    
  end

  // Assign valid output for 2-stage pipeline
  assign valid_out = valid_out_s1 & ~valid_out_s2; 

  // Assign final result
  assign result = accumulation_reg; 

endmodule