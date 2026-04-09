
module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out                 // Encoded output with parity bits
);

integer i; 
wire parity_bits;                                                            

// Calculate the number of parity bits
parameter PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);

// Compute parity bits for Hamming ECC
parity_bits = gen_parity_bits(DATA_WIDTH, PARITY_BITS);

assign parity_bits = ^data_in;

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH-1-i];
            end
            for (i = DATA_WIDTH; i < DATA_WIDTH + PARITY_BITS; i = i + 1) begin
                ecc_out[i] = parity_bits[i - DATA_WIDTH];
            end
        end
        
        2'b01: begin
            // Similar structure for 2'b01
        end
        
        2'b10: begin
            // Similar structure for 2'b10
        end
        
        2'b11: begin
            // Similar structure for 2'b11
        end
        
        default: begin
            for (i = 0; i < DATA_WIDTH + PARITY_BITS; i = i + 1) begin
                ecc_out[i] = data_in[i - DATA_WIDTH];
            end
        end
    endcase
end

endmodule
