module inter_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter SUB_BLOCKS    = 4,
    parameter DATA_WIDTH    = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input  logic clk,
    input  logic rst_n,
    input  logic i_valid,
    input  logic [DATA_WIDTH-1:0] in_data, // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

localparam CHUNK = 8;
localparam NBW_COUNTER = $clog2(SUB_BLOCKS) + 1;
localparam NBW_COUNTER_SUB_OUT = 2;
localparam OUT_CYCLES = 32;
localparam NBW_COUNTER_OUTPUT = $clog2(OUT_CYCLES);
logic [NBW_COUNTER_OUTPUT-1:0] counter_output;
logic [NBW_COUNTER-1:0] counter_sub_blocks;

logic [DATA_WIDTH-1:0] out_data_intra_block [SUB_BLOCKS-1:0];
logic [DATA_WIDTH-1:0] out_data_aux [SUB_BLOCKS-1:0];
logic start_intra;

always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      counter_sub_blocks <= {NBW_COUNTER{1'b0}};
      start_intra <= 0;
      // Removed unused in_data_reg array
   end
   else begin
      if(i_valid) begin
         // Removed unused in_data_reg[counter_sub_blocks] <= in_data;
         if(counter_sub_blocks == SUB_BLOCKS) begin
            counter_sub_blocks <= {NBW_COUNTER{1'b0}};
         end
         else begin
            start_intra <= 0;
            counter_sub_blocks <= counter_sub_blocks + 1;
         end
      end
      else if(counter_sub_blocks == SUB_BLOCKS) begin
         start_intra        <= 1;
         counter_sub_blocks <= {NBW_COUNTER{1'b0}};
      end
   end
end

// Remove the generate block for intra_block instantiation

always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      // Removed unused for-loop and out_data_intra_block_reg array
   end
   else begin
      if(start_intra) begin
         // Removed unused for-loop and out_data_intra_block_reg array
         // Combine the assignment of out_data_aux and out_data in a single blocking assignment
         out_data <= out_data_aux[counter_sub_output];
      end
   end
end

endmodule
