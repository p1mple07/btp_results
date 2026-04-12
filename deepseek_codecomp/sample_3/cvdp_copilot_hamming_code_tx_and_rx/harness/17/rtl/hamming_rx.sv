module hamming_rx 
#(
parameter DATA_WIDTH   = 4,
parameter PARITY_BIT   = 3,
parameter ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1,
parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)
(
  input[ENCODED_DATA-1:0] data_in, 
  output reg[DATA_WIDTH-1:0] data_out
);
  
reg [ENCODED_DATA_BIT-1:0] parity,count;

reg [ENCODED_DATA_BIT:0] j,i,k;

always@(*)
begin
 // STEP 1: clearing all internal reg 
 parity       = {ENCODED_DATA_BIT{1'b0}};
 data_out     = {DATA_WIDTH{1'b0}};
 count        = 0;
 i            = 0;
 j            = 0;
 k            = 0;
  
  //STEP 2: calculate even parity with respect to hamming code (Error detection)
 for (j = 0; j < ENCODED_DATA_BIT; j = j + 1) 
 begin
   for (i = 1; i <= ENCODED_DATA-1; i = i + 1) 
   begin
     if ((i & (1 << j)) != 0) 
     begin
        parity[j] = parity[j] ^ data_in[i];
     end
   end
 end
    
 // Step 3: Error correction and fetch corrected data bits from encoded input
 for (k = 1; k < ENCODED_DATA; k = k + 1) 
 begin
   if ((k & (k - 1)) != 0) 
   begin // Skip positions that are powers of 2 (parity positions)
     if (k == parity) 
     begin
       // If error detected at position k, correct the bit by inverting it
       data_out[count] = ~data_in[k];
     end 
     else 
     begin
       // Otherwise, assign the data bit to the output
        data_out[count] = data_in[k];
     end
    count = count + 1; 
   end
 end
    
end 

endmodule 