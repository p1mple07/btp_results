module hamming_rx (
  input[ENCODED_DATA-1:0] data_in,
  output [DATA_WIDTH-1:0] data_out
);
 
  wire c1,c2,c3,error;
  reg[ENCODED_DATA-1:0] correct_data;
 
 
  // Calculate parity bits
  integer p = PARITY_BIT;
  integer m = DATA_WIDTH;
  integer i;
  
  assign c1 = 0;
  assign c2 = 0;
  assign c3 = 0;
  
  for (i = 0; i < ENCODED_DATA; i++) {
    if ((i & 1) != 0) c1 ^= data_in[i];
    if ((i & 2) != 0) c2 ^= data_in[i];
    if ((i & 4) != 0) c3 ^= data_in[i];
  }
 
  assign error = ({c3,c2,c1} == 0) ? 1'b0 : 1'b1;
 
  always@(*)
  begin
    correct_data = 0;
    if(error) begin
      if ({c1,c2,c3} != 0) begin
        correct_data = data_in;
        correct_data[{c1,c2,c3}] = ~correct_data[{c1,c2,c3}];
      end
    end
  end
 
  assign data_out = {correct_data[7],correct_data[6],correct_data[5],correct_data[3]};
 
endmodule