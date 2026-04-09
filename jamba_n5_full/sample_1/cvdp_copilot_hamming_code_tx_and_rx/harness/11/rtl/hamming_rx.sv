module hamming_rx #(
  parameter DATA_WIDTH = 4,
  parameter PARITY_BIT = 3
) (
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH-1:0] data_out
);

  reg [7:0] correct_data;

  initial begin
    correct_data = data_in;
  end

  assign error = ((PARITY_BIT > 0) && ((data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3]) != 0));
  if (error)
    correct_data = data_in ^ data_in[0];
  else
    correct_data = data_in;

  assign data_out = {correct_data[7], correct_data[6], correct_data[5], correct_data[3]};

endmodule
