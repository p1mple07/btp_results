module hamming_rx #(parameter DATA_WIDTH=4, parameter PARITY_BIT=3, parameter ENCODED_DATA=8, parameter ENCODED_DATA_BIT=3) (
  input [Encoded_Data-1:0] data_in,
  output [DATA_WIDTH-1:0] data_out
);

  wire [PARITY_BIT-1:0] parity;
  wire [PARITY_BIT-1:0] parity_check;
  wire [DATA_WIDTH-1:0] corrected_data;
  
  always @*
  begin
    // Initialization
    parity <= 0;
    
    // Error Detection Using Even Parity Logic
    for (int i=0; i<PARITY_BIT; i++)
    begin
      parity[i] = |(data_in & {{1{~parity_check[i]}}, 1'b1});
    }
    
    // Error Correction
    parity_check = (parity == 0)? 0 : 1;
    
    // Output Assignment
    corrected_data = data_in;
    corrected_data[{PARITY_BIT-1:0}] = ~parity_check;
    data_out = corrected_data[DATA_WIDTH-1:0];
    
  end
  
endmodule