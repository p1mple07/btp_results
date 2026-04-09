module inter_block #(
  parameter ROW_COL_WIDTH = 16,
  parameter DATA_WIDTH      = ROW_COL_WIDTH * ROW_COL_WIDTH
)(
  input  logic clk,
  input  logic rst_n,
  input  logic i_valid,
  input  logic [DATA_WIDTH-1:0] in_data,
  output logic [DATA_WIDTH-1:0] out_data
);

  localparam CHUNK         = 8;
  localparam NBW_COUNTER    = $clog2(4) + 1;
  localparam NBW_COUNTER_SUB_OUT = $clog2(32) + 1;
  localparam OUT_CYCLES       = 32;
  localparam NBW_COUNTER_OUTPUT = $clog2(OUT_CYCLES);

  logic [NBB_COUNTER-1:0] counter_output;
  logic [NBB_COUNTER-1:0] counter_sub_blocks;
  logic [NBB_COUNTER-1:0] counter_sub_out;
  logic [NBB_COUNTER_OUTPUT-1:0] counter_output;

  logic [DATA_WIDTH-1:0] in_data_reg[3];
  logic [DATA_WIDTH-1:0] out_data_intra_block_reg[3];

  logic [DATA_WIDTH-1:0] out_data_aux[3];

  logic [DATA_WIDTH-1:0] out_data_inter_block[3];

  always_ff @(posedge clk or negedge rst_n ) begin
     if(!rst_n) begin
        for(int i = 0; i < 4; i++) begin
           in_data_reg[i] <= {DATA_WIDTH{1'b0}};
        end
        else if(i_valid) begin
           for(int i = 0; i < 4; i++) begin
              in_data_reg[i] <= {DATA_WIDTH{1'b0}};
           end
        else
           for(int i = 0; i < 4; i++) begin
              in_data_reg[i] <= {DATA_WIDTH{1'b0}};
           end
        for(int i = 0; i < 4; i++) begin
           if(i == 0) begin
              out_data[i] <= in_data_reg[i], in_data_aux[i] = {DATA_WIDTH{1'b0};
              for(int i = 0; i < 4; i++) begin
                 out_data[i] <= {DATA_WIDTH{1'b0};
                 for(int i = 0; i < 4; i++) begin
                    out_data[i] <= {DATA_WIDTH{1'b0} to ensure the output files.
                 end
             end
         }
    }