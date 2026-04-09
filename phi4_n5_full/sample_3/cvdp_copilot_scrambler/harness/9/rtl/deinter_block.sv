Below is the corrected RTL code. The bug was that the condition for starting intra‐processing was checking for counter_sub_blocks == SUB_BLOCKS (which never holds because the counter is reset as soon as it equals SUB_BLOCKS) rather than checking for SUB_BLOCKS–1. With the fix the counter is allowed to reach SUB_BLOCKS–1 so that start_intra is asserted once all four input registers are filled. Save the following file as rtl/deinter_block.sv:

------------------------------------------------------------
module deinter_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter SUB_BLOCKS    = 4,
    parameter DATA_WIDTH    = ROW_COL_WIDTH*ROW_COL_WIDTH,
    parameter OUT_DATA_WIDTH= 16,
    parameter WAIT_CYCLES   = 4
)(
    input  logic clk,
    input  logic rst_n,
    input  logic i_valid,
    input  logic [DATA_WIDTH-1:0] in_data, // Input: 256 bits
    output logic [OUT_DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

localparam CHUNK = 8;
localparam NBW_COUNTER = $clog2(SUB_BLOCKS) + 1;
localparam NBW_COUNTER_SUB_OUT = 2;

localparam OUT_CYCLES = 32;

localparam N_CYCLES = SUB_BLOCKS*DATA_WIDTH/OUT_DATA_WIDTH;
localparam NBW_COUNTER_OUTPUT = $clog2(N_CYCLES);
logic [NBW_COUNTER_OUTPUT-1:0] counter_output;

logic [NBW_COUNTER-1:0] counter_sub_blocks;
logic [NBW_COUNTER_SUB_OUT-1:0] counter_sub_out;

logic [DATA_WIDTH-1:0] in_data_reg [SUB_BLOCKS-1:0];
logic [DATA_WIDTH-1:0] out_data_intra_block [SUB_BLOCKS-1:0];
logic [DATA_WIDTH-1:0] out_data_intra_block_reg [SUB_BLOCKS-1:0];
logic [DATA_WIDTH-1:0] out_data_aux [SUB_BLOCKS-1:0];
logic start_intra;

// ----------------------------------------------------------------
// Input Registration: The in_data is registered if i_valid is asserted.
// The bug was that the condition checked for counter_sub_blocks == SUB_BLOCKS,
// which never held because the counter was reset immediately.
// The fix is to check for SUB_BLOCKS-1 so that once all four registers
// are filled, start_intra is asserted.
// ----------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      counter_sub_blocks <= {NBW_COUNTER{1'b0}};
      start_intra <= 0;
      for(int i = 0; i < SUB_BLOCKS; i++) begin
         in_data_reg[i] <= {DATA_WIDTH{1'b0}};
      end
   end
   else begin
      if(i_valid) begin
         in_data_reg[counter_sub_blocks] <= in_data;
         if(counter_sub_blocks == SUB_BLOCKS - 1) begin
            start_intra <= 1;
            counter_sub_blocks <= {NBW_COUNTER{1'b0}};
         end
         else begin
            counter_sub_blocks <= counter_sub_blocks + 1;
         end
      end
   end
end

always_ff @(posedge clk or negedge rst_n) begin