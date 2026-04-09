module cascaded_adder #(
    parameter int IN_DATA_WIDTH = 16,
    parameter int IN_DATA_NS = 4,
    parameter int NUM_STAGES = $clog2(IN_DATA_NS),
    parameter logic [NUM_STAGES-1:0] REG = {NUM_STAGES{1'b1}}
) (
   input  logic clk,
   input  logic rst_n,
   input  logic i_valid,
   input  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data,
   output logic o_valid,
   output logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] o_data
);

   // Internal signals for the adder tree
   logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data_ff;
   logic [IN_DATA_WIDTH-1:0] in_data_2d [IN_DATA_NS-1:0];
   logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] stage_output [NUM_STAGES-1:0][IN_DATA_NS>>1-1:0];
   logic valid_ff;
   logic valid_pipeline [NUM_STAGES-1:0];

   // Register the input data on valid signal
   always_ff @(posedge clk or negedge rst_n) begin : reg_indata
      if(!rst_n)
         i_data_ff <= 0;
      else begin
         if(i_valid) begin
            i_data_ff <= i_data;
         end
      end
   end

   // Convert flattened input to 2D array
   always_comb begin
      for (int i = 0; i < IN_DATA_NS; i++) begin : conv_1d_to_2d
         in_data_2d[i] = i_data_ff[(i+1)*IN_DATA_WIDTH-1 -: IN_DATA_WIDTH];
      end
   end

   // Parallel addition using combinational logic
   always_comb begin
      for (int stage = 0; stage < NUM_STAGES; stage++) begin
         for (int i = 0; i < IN_DATA_NS; i++) begin
            stage_output[stage][i] = stage_output[stage-1][i] + stage_output[stage][i];
         end
      end
   end

   // Compute the final output data
   stage_output[NUM_STAGES-1][0] = stage_output[NUM_STAGES-1][0];
   for (int i = 1; i < IN_DATA_NS; i++) stage_output[NUM_STAGES-1][i] = stage_output[NUM_STAGES-1][i-1] + stage_output[NUM_STAGES-1][i];

   // Set the valid output signal
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
         o_valid <= 1'b0;
      else
         o_valid <= valid_pipeline[NUM_STAGES-1];
   end

   // Assign the output data
   always_ff @(posedge clk or negedge rst_n) begin : reg_outdata
      if ( !rst_n) begin
         o_data <= 0;
      end else if (valid_pipeline[NUM_STAGES-1]) begin
         o_data <= stage_output[NUM_STAGES-1][0];
      end
   end

endmodule
