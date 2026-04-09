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
   logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] stage_output [NUM_STAGES-1:0][IN_DATA_NS>>1-1:0];
   logic valid_ff;
   logic valid_pipeline [NUM_STAGES-1:0];  // Pipeline to handle the valid signal latencies based on REG
   
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

   // Parallel logic of the adder tree using generate statements
   

   always_ff @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         valid_ff <= 1'b0;
      else 
         valid_ff <= i_valid;
   end


   // Valid signal propagation with latency based on REG


   // Assign the final stage of valid_pipeline to o_valid
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         o_valid <= 1'b0;
      end else if (valid_pipeline[NUM_STAGES-1]) begin
         o_valid <= valid_pipeline[NUM_STAGES-1];
      end
   end

   // Output data assignment
   always_ff @(posedge clk or negedge rst_n) begin : reg_outdata
      if (!rst_n) begin
         o_data <= 0 ;
      end else if (valid_pipeline[NUM_STAGES-1]) begin
         o_data <= stage_output[NUM_STAGES-1][0];
      end
   end

endmodule