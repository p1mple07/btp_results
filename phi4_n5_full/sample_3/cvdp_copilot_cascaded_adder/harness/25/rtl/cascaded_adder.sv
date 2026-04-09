module cascaded_adder #(
    parameter int IN_DATA_WIDTH = 16,                       // Width of each input data
    parameter int IN_DATA_NS = 4,                           // Number of input data elements
    parameter int NUM_STAGES = $clog2(IN_DATA_NS),          // Number of summation stages (calculated once)
    parameter logic [NUM_STAGES-1:0] REG = {NUM_STAGES{1'b1}}  // Control bits for register insertion
) (
   input  logic clk,
   input  logic rst_n,
   input  logic i_valid, 
   input  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data,  // Flattened input data array
   output logic o_valid,
   output logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] o_data // Output data (sum)
);
 
   // Internal signals for the adder tree
   logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data_ff;                             // Flattened input data array register
   logic [IN_DATA_WIDTH-1:0] in_data_2d [IN_DATA_NS-1:0];                      // Intermediate 2D array
   // Note: stage_output is dimensioned with maximum number of elements per stage.
   // For stage j, only indices 0 to (IN_DATA_NS >> (j+1))-1 are used.
   logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] stage_output [NUM_STAGES-1:0][IN_DATA_NS>>1-1:0];
   logic valid_ff;
   logic valid_pipeline [NUM_STAGES-1:0];  // Pipeline to handle the valid signal latencies based on REG
   
   // Register the input data on valid signal
   always_ff @(posedge clk or negedge rst_n) begin : reg_indata
      if(!rst_n)
         i_data_ff <= 0;
      else begin
         if(i_valid)
            i_data_ff <= i_data;
      end
   end

   // Convert flattened input to 2D array
   always_comb begin
       for (int i = 0; i < IN_DATA_NS; i++) begin : conv_1d_to_2d
           in_data_2d[i] = i_data_ff[(i+1)*IN_DATA_WIDTH-1 -: IN_DATA_WIDTH];
       end
   end

   // -------------------------------------------------------------------
   // Adder tree generation using generate statements
   // -------------------------------------------------------------------
   generate
      for (genvar j = 0; j < NUM_STAGES; j = j + 1) begin : adder_tree_stage
         if (j == 0) begin
            // Stage 0: Sum pairs from in_data_2d.
            // There are (IN_DATA_NS >> 1) pairs.
            for (genvar i = 0; i < (IN_DATA_NS >> 1); i = i + 1) begin : stage0_pair
               if (REG[0] == 1) begin
                  always_ff @(posedge clk or negedge rst_n) begin
                     if (!rst_n)
                        stage_output[0][i] <= 0;
                     else if (valid_pipeline[0])
                        stage_output[0][i] <= in_data_2d[2*i] + in_data_2d[2*i+1];
                  end
               end else begin
                  assign stage_output[0][i] = in_data_2d[2*i] + in_data_2d[2*i+1];
               end
            end
         end else begin
            // Stage j: Sum pairs from the previous stage (stage_output[j-1]).
            // There are (IN_DATA_NS >> (j+1)) pairs.
            for (genvar i = 0; i < (IN_DATA_NS >> (j+1)); i = i + 1) begin : stageX_pair
               if (REG[j] == 1) begin
                  always_ff @(posedge clk or negedge rst_n) begin
                     if (!rst_n)
                        stage_output[j][i] <= 0;
                     else if (valid_pipeline[j])
                        stage_output[j][i] <= stage_output[j-1][2*i] + stage_output[j-1][2*i+1];
                  end
               end else begin
                  assign stage_output[j][i] = stage_output[j-1][2*i] + stage_output[j-1][2*i+1];
               end
            end
         end
      end
   endgenerate

   // -------------------------------------------------------------------
   // Valid signal propagation with latency based on REG
   // -------------------------------------------------------------------
   // First, register the input valid signal.
   always_ff @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         valid_ff <= 1'b0;
      else 
         valid_ff <= i_valid;
   end

   generate
      // Stage 0 valid propagation: valid_pipeline[0] gets valid_ff.
      always_ff @(posedge clk or negedge rst_n) begin
         if (!rst_n)
            valid_pipeline[0] <= 1'b0;
         else
            valid_pipeline[0] <= valid_ff;
      end

      // For stages 1 to NUM_STAGES-1, propagate the valid signal.
      for (genvar j = 1; j < NUM_STAGES; j = j + 1) begin : valid_pipeline_stage
         if (REG[j] == 1) begin
            always_ff @(posedge clk or negedge rst_n) begin
               if (!rst_n)
                  valid_pipeline[j] <= 1'b0;
               else
                  valid_pipeline[j] <= valid_pipeline[j-1];
            end
         end else begin
            assign valid_pipeline[j] = valid_pipeline[j-1];
         end
      end
   endgenerate

   // Assign the final stage of valid_pipeline to o_valid.
   always_ff @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         o_valid <= 1'b0;
      else
         o_valid <= valid_pipeline[NUM_STAGES-1];
   end

   // Output data assignment: hold the computed sum until a new computation.
   always_ff @(posedge clk or negedge rst_n) begin : reg_outdata
      if (!rst_n)
         o_data <= 0;
      else if (valid_pipeline[NUM_STAGES-1])
         o_data <= stage_output[NUM_STAGES-1][0];
   end

endmodule