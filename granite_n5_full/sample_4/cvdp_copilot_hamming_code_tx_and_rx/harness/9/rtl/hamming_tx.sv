module hamming_tx #(
  parameter int DATA_WIDTH = 4,
  parameter int PARITY_BIT = 3
) (
  input  wire [DATA_WIDTH-1:0] data_in,
  output reg  [Encoded_DATA-1:0] data_out
);

  localparam int ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
  localparam int ENCODED_DATA_BIT = $clog2(ENCODED_DATA);
  reg [DATA_WIDTH-1:0] data_in;
  reg [PARITY_BIT-1:0] parity;
  
  always @(posedge clk) begin
    data_out <= {1'b0, data_in};
    
    parity[0] <= data_out[1] ^ data_out[3] ^ data_out[5] ^ data_out[7];
    parity[1] <= data_out[2] ^ data_out[3] ^ data_out[6] ^ data_out[7];
    parity[2] <= data_out[1] ^ data_out[2] ^ data_out[3] ^ data_out[4];
    
    data_out <= {parity[0], parity[1], parity[2], data_in};
    
  endgenerate
  
endmodule