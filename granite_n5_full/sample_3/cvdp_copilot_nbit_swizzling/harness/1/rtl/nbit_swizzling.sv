module nbit_swizzling #(
  parameter int unsigned DATA_WIDTH = 64 // Data width in bits
) (
  input logic [DATA_WIDTH-1:0] data_in,  // Input data
  input logic [1:0] sel,                // Selection signal
  output logic [DATA_WIDTH-1:0] data_out // Output data
);

  // Reverse the entire input when sel=0
  assign data_out = (sel == 0)? data_in : {{(DATA_WIDTH/2){1'b0}}, data_in};

  // Reverse the first half of the input when sel=1
  generate
    if (DATA_WIDTH % 2 == 0) begin : even_width
      assign data_out[DATA_WIDTH/2-1:0] = {{(DATA_WIDTH/2){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/2]};
    end else begin : odd_width
      assign data_out[DATA_WIDTH/2] = data_in[DATA_WIDTH-1];
      assign data_out[DATA_WIDTH/2-1:0] = {{(DATA_WIDTH/2){1'b0}}, data_in[DATA_WIDTH-2:DATA_WIDTH/2+1]};
    end
  endgenerate

  // Reverse the second half of the input when sel=2
  generate
    if (DATA_WIDTH % 4 == 0) begin : multiple_of_4
      assign data_out[(DATA_WIDTH/4)-1:0] = {{(DATA_WIDTH/4){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/4*3]};
      assign data_out[(DATA_WIDTH/4)*1:DATA_WIDTH/4] = {{(DATA_WIDTH/4){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/4*2]};
      assign data_out[(DATA_WIDTH/4)*2:DATA_WIDTH/4*3] = {{(DATA_WIDTH/4){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/4]};
    end else begin : not_multiple_of_4
      assign data_out[(DATA_WIDTH/4)-1:0] = {{(DATA_WIDTH/4){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/4*3]};
      assign data_out[(DATA_WIDTH/4)*1:DATA_WIDTH/4] = {{(DATA_WIDTH/4){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/4*2]};
      assign data_out[(DATA_WIDTH/4)*2:DATA_WIDTH/4*3] = {{(DATA_WIDTH/4){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/4]};
      assign data_out[(DATA_WIDTH/4)*3:DATA_WIDTH/4*4-1] = {{(DATA_WIDTH/4){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/4*4-1]};
    end
  endgenerate

  // Reverse the last 4 sections of the input when sel=3
  generate
    if (DATA_WIDTH % 8 == 0) begin : multiple_of_8
      assign data_out[(DATA_WIDTH/8)-1:0] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*7]};
      assign data_out[(DATA_WIDTH/8)*1:DATA_WIDTH/8] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*6]};
      assign data_out[(DATA_WIDTH/8)*2:DATA_WIDTH/8*3] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*5]};
      assign data_out[(DATA_WIDTH/8)*3:DATA_WIDTH/8*4] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*4]};
      assign data_out[(DATA_WIDTH/8)*4:DATA_WIDTH/8*5] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*3]};
      assign data_out[(DATA_WIDTH/8)*5:DATA_WIDTH/8*6] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*2]};
      assign data_out[(DATA_WIDTH/8)*6:DATA_WIDTH/8*7] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*1]};
      assign data_out[(DATA_WIDTH/8)*7:DATA_WIDTH/8*8-1] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*0]};
    end else begin : not_multiple_of_8
      assign data_out[(DATA_WIDTH/8)-1:0] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*7]};
      assign data_out[(DATA_WIDTH/8)*1:DATA_WIDTH/8] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*6]};
      assign data_out[(DATA_WIDTH/8)*2:DATA_WIDTH/8*3] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*5]};
      assign data_out[(DATA_WIDTH/8)*3:DATA_WIDTH/8*4] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*4]};
      assign data_out[(DATA_WIDTH/8)*4:DATA_WIDTH/8*5] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*3]};
      assign data_out[(DATA_WIDTH/8)*5:DATA_WIDTH/8*6] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*2]};
      assign data_out[(DATA_WIDTH/8)*6:DATA_WIDTH/8*7] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:DATA_WIDTH/8*1]};
      assign data_out[(DATA_WIDTH/8)*7:DATA_WIDTH/8*8-1] = {{(DATA_WIDTH/8){1'b0}}, data_in[DATA_WIDTH-1:0]};
    end
  endgenerate

endmodule