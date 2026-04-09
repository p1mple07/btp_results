module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input  [DATA_WIDTH-1:0] data_in,
    input  [1:0]             sel,
    output reg [DATA_WIDTH:0] data_out,
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1)-1:0] ecc_out
);

  // Local parameters for Hamming ECC
  localparam int PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);
  localparam int TOTAL_BITS  = DATA_WIDTH + PARITY_BITS;

  integer i;
  wire parity_bit;
  assign parity_bit = ^data_in;

  // Existing swizzling logic for data_out based on sel
  always @(*) begin
      case(sel)
          2'b00: begin
              for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                  data_out[i] = data_in[DATA_WIDTH-1-i];                      
              end
              data_out[DATA_WIDTH] = parity_bit; 
          end
          
          2'b01: begin
              for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                  data_out[i]                = data_in[DATA_WIDTH/2-1-i];     
                  data_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];       
              end
              data_out[DATA_WIDTH] = parity_bit; 
          end
          
          2'b10: begin
              for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                  data_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            
                  data_out[DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   
                  data_out[DATA_WIDTH/2 + i]   = data_in[3*DATA_WIDTH/4-1-i]; 
                  data_out[3*DATA_WIDTH/4 + i] = data_in[DATA_WIDTH-1-i];     
              end
              data_out[DATA_WIDTH] = parity_bit; 
          end
          
          2'b11: begin
              for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                  data_out[i]                  = data_in[DATA_WIDTH/8-1-i];   
                  data_out[DATA_WIDTH/8 + i]   = data_in[DATA_WIDTH/4-1-i];   
                  data_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/8-1-i]; 
                  data_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/2-1-i];   
                  data_out[DATA_WIDTH/2 + i]   = data_in[5*DATA_WIDTH/8-1-i]; 
                  data_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i]; 
                  data_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i]; 
                  data_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];     
              end
              data_out[DATA_WIDTH] = parity_bit; 
          end
          default: begin
              data_out = data_in;	
              data_out[DATA_WIDTH] = parity_bit; 					                        
          end
      endcase
  end

  // Hamming ECC Generation: Build ecc_out by inserting parity bits at positions that are powers of 2
  always @(*) begin
      reg [TOTAL_BITS-1:0] encoded;
      integer j, k;
      reg bit;
      encoded = {TOTAL_BITS{1'b0}};
      
      // Fill non-parity positions with data_in bits in order.
      // Positions are numbered 1 to TOTAL_BITS (1-indexed); parity positions are those where (k & (k-1)) == 0.
      j = 0;
      for (k = 1; k <= TOTAL_BITS; k = k + 1) begin
           if ((k & (k-1)) != 0) begin
                encoded[k-1] = data_in[j];
                j = j + 1;
           end
      end
      
      // Compute parity bits using XOR logic.
      // For each parity position (k is a power of 2), XOR all bits whose (1-indexed) position has a 1 in the k-th bit.
      for (k = 1; k <= TOTAL_BITS; k = k + 1) begin
           if ((k & (k-1)) == 0) begin
                bit = 1'b0;
                for (j = 1; j <= TOTAL_BITS; j = j + 1) begin
                    if ((j & k) != 0)
                        bit = bit ^ encoded[j-1];
                end
                encoded[k-1] = bit;
           end
      end
      
      ecc_out = encoded;
  end

endmodule