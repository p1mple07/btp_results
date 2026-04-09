module inter_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH    = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input  logic clk,
    input  logic rst_n,
    input  logic i_valid,
    input  logic [DATA_WIDTH-1:0] in_data, // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

localparam OUT_CYCLES = 32;
localparam NBW_COUNTER = $clog2(OUT_CYCLES);
logic [NBW_COUNTER-1:0] counter_output;

logic [DATA_WIDTH-1:0] in_data_reg;
logic [DATA_WIDTH-1:0] out_data_intra_block;
logic [DATA_WIDTH-1:0] out_data_intra_block_reg;
logic [DATA_WIDTH-1:0] out_data_aux;
logic start_intra;

always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      counter_output <= {NBW_COUNTER{1'b0}};
      start_intra <= 0;
      for(int i = 0; i < ROW_COL_WIDTH; i++) begin
         in_data_reg[i] <= {DATA_WIDTH{1'b0}};
      end
   else begin
      if(i_valid) begin
         in_data_reg <= in_data;
         if(counter_output == NBW_COUNTER) begin
            counter_output <= {NBW_COUNTER{1'b0}};
         end else begin
            start_intra <= 0;
            counter_output <= counter_output + 1;
         end
      end
      else if(counter_output == NBW_COUNTER) begin
         start_intra <= 1;
         counter_output <= {NBW_COUNTER{1'b0}};
      end
   end
end

generate
   intra_block (
      .in_data(in_data_reg),
      .out_data(out_data_intra_block)
   );
endgenerate

always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      out_data_intra_block_reg <= {DATA_WIDTH{1'b0}};
   end
   else begin
      if(start_intra) begin
         out_data_intra_block_reg <= out_data_intra_block;
      end
   end
end

always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      counter_output <= {NBW_COUNTER{1'b1}};
      out_data <= {DATA_WIDTH{1'b0}};
      out_data_aux <= {DATA_WIDTH{1'b0}};
   end
   else begin
      if(start_intra) begin
         for(int i = 0; i < 32; i++) begin
            out_data_aux[i] <= out_data_intra_block_reg[i];
         end
         counter_output <= counter_output + 1;
         out_data <= out_data_aux[counter_output];
      end
   end
end

endmodule