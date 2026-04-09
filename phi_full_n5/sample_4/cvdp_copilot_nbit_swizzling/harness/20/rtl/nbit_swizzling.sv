
module nbit_swizzling #(parameter DATA_WIDTH = 16) (
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out                  // Encoded output with parity bits
);

integer i, j, parity_bit_pos;
wire [DATA_WIDTH:0] parity_bits;

// Calculate number of parity bits
parameter PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);

// Compute and place parity bits
always @(*) begin
    for (i = 0; i < PARITY_BITS; i = i + 1) begin
        parity_bit_pos = POWER2(i);
        parity_bits[parity_bit_pos] = ^data_in;
    end
end

// Generate swizzled data
always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH-1-i];
            end
            for (j = 0; j < PARITY_BITS; j = j + 1) begin
                ecc_out[DATA_WIDTH + j] = parity_bits[j];
            end
        end
        
        2'b01: begin
            // Similar logic for 2'b01 case
        end
        
        2'b10: begin
            // Similar logic for 2'b10 case
        end
        
        2'b11: begin
            // Similar logic for 2'b11 case
        end
        
        default: begin
            for (i = 0; i < DATA_WIDTH + PARITY_BITS; i = i + 1) begin
                ecc_out[i] = data_in[i];
            end
        end
    endcase
end

endmodule
