
module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out                  // Encoded output with parity bits
);

integer i;
wire parity_bits;
wire [DATA_WIDTH-1:0] parity_data;

// Calculate the number of parity bits
parameter PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);

// Compute parity bits using XOR logic
always @(*) begin
    parity_bits = 0;
    for (i = 0; i < PARITY_BITS; i = i + 1) begin
        for (j = 0; j < DATA_WIDTH; j = j + 1) begin
            if (j & (1 << i)) begin
                parity_bits = parity_bits ^ data_in[j];
            end
        end
    end
end

// Place parity bits at positions that are powers of 2
assign ecc_out[PARITY_BITS-1:0] = {parity_bits};

// Combine data_in and parity bits into ecc_out
assign ecc_out[DATA_WIDTH + PARITY_BITS-1:0] = data_in;

endmodule
