module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,                     // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                    // 2-bit selection signal 
    output reg [DATA_WIDTH+7:0] ecc_out                    // Encoded output with parity bits 
);

localparam PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH)) + 1;

// Generate parity bits
wire [PARITY_BITS-1:0] parity_bits;
generate
    for (genvar i = 0; i < PARITY_BITS; i++) begin
        assign parity_bits[i] = (data_in >> (i * (DATA_WIDTH / PARITY_BITS))) & ((1 << (DATA_WIDTH / PARITY_BITS)) - 1);
    end
endgenerate

// Concatenate data_in and parity_bits
assign ecc_out = {data_in, parity_bits};

endmodule