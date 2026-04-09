cascaded_adder.sv
------------------------------------------------------------
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
   // Note: For stage 0, we have (IN_DATA_NS >> 1) partial sums; for stage 1, (IN_DATA_NS >> 2), etc.
   logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] stage_output [NUM_STAGES-1:0][(IN_DATA_NS >> 1)-1:0];
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

   //--------------------------------------------------------------------------
   // Parallel Adder Tree Generation
   //--------------------------------------------------------------------------
   generate
      for (genvar stage = 0; stage < NUM_STAGES; stage++) begin : gen_stage
         integer j;
         if (stage == 0) begin
            // Stage 0: Sum pairs from the 2D array
            if (REG[stage]) begin : stage0_reg
               always_ff @(posedge clk or negedge rst_n) begin
                  if (!rst_n) begin
                     for (j = 0; j < (IN_DATA_NS >> 1); j = j + 1)
                        stage_output[stage][j] <= 0;
                  end else if (valid_ff) begin
                     for (j = 0; j < (IN_DATA_NS >> 1); j = j + 1)
                        stage_output[stage][j] <= in_data_2d[2*j] + in_data_2d[2*j+1];
                  end
               end
            end else begin : stage0_comb
               always_comb begin
                  for (j = 0; j <