module nbit_swizzling (
  input wire [DATA_WIDTH-1:0] data_in,
  input wire [1:0] sel,
  output wire [DATA_WIDTH-1:0] data_out
);

  always @(*) begin
    case (sel)
      2'b00:
        data_out <= data_in;
      2'b01:
        begin
          data_out[DATA_WIDTH-1:DATA_WIDTH/2] = data_in[DATA_WIDTH/2-1:0];
          data_out[DATA_WIDTH/2-1:0] = data_in[DATA_WIDTH-1:DATA_WIDTH/2];
        end
      2'b10:
        begin
          data_out[DATA_WIDTH-1:DATA_WIDTH/4] = data_in[DATA_WIDTH/4-1:0];
          data_out[DATA_WIDTH/4-1:DATA_WIDTH/2] = data_in[DATA_WIDTH/2-1:DATA_WIDTH/4];
          data_out[DATA_WIDTH/2-1:DATA_WIDTH/4*3] = data_in[DATA_WIDTH/4*3-1:DATA_WIDTH/4];
          data_out[DATA_WIDTH/4*3-1:DATA_WIDTH/4*2] = data_in[DATA_WIDTH/4*2-1:DATA_WIDTH/4*3];
        end
      2'b11:
        begin
          data_out[DATA_WIDTH-1:DATA_WIDTH/8] = data_in[DATA_WIDTH/8-1:0];
          data_out[DATA_WIDTH/8-1:DATA_WIDTH/4] = data_in[DATA_WIDTH/4-1:DATA_WIDTH/8];
          data_out[DATA_WIDTH/4-1:DATA_WIDTH/8*3] = data_in[DATA_WIDTH/8*3-1:DATA_WIDTH/8*2];
          data_out[DATA_WIDTH/8*3-1:DATA_WIDTH/8*2] = data_in[DATA_WIDTH/8*2-1:DATA_WIDTH/8*3];
          data_out[DATA_WIDTH/8*5-1:DATA_WIDTH/8*4] = data_in[DATA_WIDTH/8*4-1:DATA_WIDTH/8*5];
          data_out[DATA_WIDTH/8*4-1:DATA_WIDTH/8*3] = data_in[DATA_WIDTH/8*3-1:DATA_WIDTH/8*4];
          data_out[DATA_WIDTH/8*7-1:DATA_WIDTH/8*6] = data_in[DATA_WIDTH/8*6-1:DATA_WIDTH/8*7];
          data_out[DATA_WIDTH/8*6-1:DATA_WIDTH/8*5] = data_in[DATA_WIDTH/8*5-1:DATA_WIDTH/8*6];
        end
      default:
        data_out <= data_in; // Handle invalid selections gracefully
    endcase
  end

endmodule