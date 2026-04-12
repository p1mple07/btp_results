module cascaded_adder #(
    parameter int IN_DATA_WIDTH = 16,  // Width of each input data
    parameter int IN_DATA_NS = 4,      // Number of input data elements
    parameter [IN_DATA_NS-1:0] REG = 4'b1010        // Control bits for register insertion
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
   logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] sum_stage [IN_DATA_NS-1:0];  // Intermediate sum array
   logic valid_ff;
   logic valid_pipeline [IN_DATA_NS-1:0];  // Pipeline to handle the valid signal latencies based on REG
   
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

   // Generate logic for the adder tree using generate statement
   genvar i;
   generate
      for (i = 0; i < IN_DATA_NS ; i++) begin : sum_stage_gen
         if(i == 0) begin
            if(REG[i]) begin
               always_ff @(posedge clk or negedge rst_n ) begin
                  if (! rst_n) begin
                     sum_stage[i] <= 0 ;
                  end
                  else begin
                      sum_stage[i] <= in_data_2d[i];
                  end
               end
            end
            else begin
               always_comb sum_stage[i] = in_data_2d[i];
            end
         end
         else begin
            if(REG[i]) begin
               always_ff @(posedge clk or negedge rst_n) begin
                  if (! rst_n) begin
                     sum_stage[i] <= 0 ;
                  end
                  else begin
                      sum_stage[i] <= sum_stage[i-1] + in_data_2d[i];
                  end
               end
            end
            else begin
               always_comb sum_stage[i] = sum_stage[i-1] + in_data_2d[i];
            end
         end
      end
   endgenerate

   always_ff @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         valid_ff <= 1'b0;
      else 
         valid_ff <= i_valid;
   end


   // Valid signal propagation with latency based on REG
   generate
      for (i = 0; i < IN_DATA_NS; i++) begin : valid_latency_gen
         if (i == 0) begin
            if (REG[0]) begin
               always_ff @(posedge clk or negedge rst_n) begin
                  if (!rst_n)
                     valid_pipeline[0] <= 1'b0;
                  else
                     valid_pipeline[0] <= valid_ff;  // Register valid_ff if REG[0] == 1
               end
            end
            else begin
               always_comb begin
                  valid_pipeline[0] = valid_ff;  // Combinational if REG[0] == 0
               end
            end
         end
         else begin
            if (REG[i]) begin
               always_ff @(posedge clk or negedge rst_n) begin
                  if (!rst_n)
                     valid_pipeline[i] <= 1'b0;
                  else
                     valid_pipeline[i] <= valid_pipeline[i-1];  // Shift the valid signal based on REG
               end
            end
            else begin
               always_comb begin
                  valid_pipeline[i] = valid_pipeline[i-1];  // No clock latency if REG[i] is 0
               end
            end
         end
      end
   endgenerate


   // Assign the final stage of valid_pipeline to o_valid
   always_ff @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         o_valid <= 1'b0;
      else
         o_valid <= valid_pipeline[IN_DATA_NS-1];
   end

   // Output data assignment
   always_ff @(posedge clk or negedge rst_n) begin : reg_outdata
      if ( !rst_n) begin
         o_data <= 0 ;
      end else begin
         o_data <= sum_stage[IN_DATA_NS-1];
      end
   end

endmodule