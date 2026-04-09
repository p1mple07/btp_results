module cascaded_adder #(
    parameter int IN_DATA_WIDTH = 16,
    parameter int IN_DATA_NS = 4,
    parameter int NUM_STAGES = $clog2(IN_DATA_NS),
    parameter logic [NUM_STAGES-1:0] REG = {NUM_STAGES{1'b1}}
) (
   input  logic clk,
   input  logic rst_n,
   input  logic i_valid, 
   input  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data,  // Flattened input data array
   output logic o_valid,
   output logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] o_data // Output data (sum)
);

// Internal signals
logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data_ff;
logic [IN_DATA_WIDTH-1:0] in_data_2d[IN_DATA_NS-1:0];
logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] stage_output[NUM_STAGES-1][IN_DATA_NS>>1-1:0];
logic valid_pipeline[NUM_STAGES-1];

// Register the input data on valid signal
always_ff @(posedge clk or negedge rst_n) begin : reg_indata
   if (!rst_n)
      i_data_ff <= 0;
   else
      if (i_valid)
         i_data_ff <= i_data;
   end
end

// Convert flattened input to 2D array
always_comb begin
   for (int i = 0; i < IN_DATA_NS; i++) begin : conv_1d_to_2d
      in_data_2d[i] = i_data_ff[(i+1)*IN_DATA_WIDTH-1 -: IN_DATA_WIDTH];
   end
end

// Insert Code here for parallel logic of the adder tree using generate statements

generate always_stage_processing
begin
   #1 clk;
end
always_comb begin
   for (g = 0; g < NUM_STAGES; g++) begin
      for (i = 0; i < IN_DATA_NS; i += 2) begin
         if (i+1 < IN_DATA_NS)
            stage_output[g][i] = i_data_2d[i];
             stage_output[g][i+1] = i_data_2d[i+1];
         else
            stage_output[g][i] = i_data_2d[i];
      end
   end
end

assign valid_pipeline[NUM_STAGES-1] = i_valid;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      valid_ff <= 1'b0;
   else
      valid_ff <= i_valid;
end

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      o_valid <= 1'b0;
   else
      o_valid <= valid_pipeline[NUM_STAGES-1];
end

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      o_data <= 0;
   else if (valid_pipeline[NUM_STAGES-1]) begin
      o_data <= stage_output[NUM_STAGES-1][0];
   end
end

endmodule
