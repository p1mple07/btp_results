module hamming_rx (
  input[ENCODED_DATA-1:0] data_in,
  output [DATA_WIDTH-1:0] data_out
);
 
  parameter PARITY_BIT = 3;
  parameter DATA_WIDTH = 4;
  parameter ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
  parameter ENCODED_DATA_BIT = log2(ENCODED_DATA);
 
  wire [ENCODED_DATA_BIT-1:0] parity;
  wire error;
  wire correct_data[ENCODED_DATA-1:0];
 
 
  assign correct_data = 0;
  assign parity[0] = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
  assign parity[1] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
  assign parity[2] = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
  assign error = parity[2] & parity[1] & parity[0];
 
  always@(*)
  begin
    correct_data = data_in;
    if(error)
    begin
      correct_data[1] = ~correct_data[1];
      correct_data[3] = ~correct_data[3];
      correct_data[5] = ~correct_data[5];
      correct_data[7] = ~correct_data[7];
    end
  end
 
  assign data_out = {correct_data[7], correct_data[6], correct_data[5], correct_data[3]};
 
endmodule