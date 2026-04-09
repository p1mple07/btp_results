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

   // Generate the adder tree
   genvar gen_i, gen_j;
   always_comb begin : gen_adder_tree
      for (gen_i = 0; gen_i < NUM_STAGES; gen_i=gen_i+1) begin : stage_gen
         if (REG[gen_i]) begin
            for (gen_j = 0; gen_j < IN_DATA_NS/2; gen_j=gen_j+1) begin : pair_gen
               wire [IN_DATA_WIDTH-1:0] sum = in_data_2d[gen_j] + in_data_2d[gen_j+IN_DATA_NS/2];
               stage_output[gen_i][gen_j] = sum;
               stage_output[gen_i][gen_j+IN_DATA_NS/2] = sum;
            end
         end
      end
   end

   // Valid signal propagation with latency based on REG
   always_ff @(posedge clk or negedge rst_n) begin : valid_pipeline_gen
      if(!rst_n)
         valid_pipeline <= 1'b0;
      else begin
         if (i_valid) begin
            valid_pipeline[NUM_STAGES-1] <= i_valid;
            for (gen_i = NUM_STAGES-2 downto 0) begin : pipeline_gen
               valid_pipeline[gen_i] <= valid_pipeline[gen_i+1] & REG[gen_i];
            end
         end
      end
   end

   // Assign the final stage of valid_pipeline to o_valid
   always_ff @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         o_valid <= 1'b0;
      else
         o_valid <= valid_pipeline[NUM_STAGES-1];
   end

   // Output data assignment
   always_ff @(posedge clk or negedge rst_n) begin : reg_outdata
      if ( !rst_n) begin
         o_data <= 0;
      end else if (valid_pipeline[NUM_STAGES-1]) begin
         o_data <= stage_output[NUM_STAGES-1][0];
      end
   end

endmodule
