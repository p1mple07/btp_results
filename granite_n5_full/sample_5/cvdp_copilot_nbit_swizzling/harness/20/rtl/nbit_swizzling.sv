module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH:0] data_out,
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH)-1:0] ecc_out
);

localparam PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH)) - 1;

reg [PARITY_BITS-1:0] parity_bits;

always @(*) begin
    parity_bits[0] = 0;
    for (int i = 0; i < DATA_WIDTH; i++) begin
        parity_bits[0] = parity_bits[0] ^ data_in[i];
    end
    for (int i = 1; i < PARITY_BITS; i++) begin
        parity_bits[i] = parity_bits[(i-1)/2] >> ((i-1)%2) ^ parity_bits[(i-1)/2+1] >> (((i-1)%2)+1);
    end
    if ($countones(parity_bits) > 1) begin
        parity_bits = ~parity_bits;
    end
    
    for (int i = 0; i < DATA_WIDTH; i++) begin
        data_out[i] = data_in[i];
    end
    for (int i = 0; i < PARITY_BITS; i++) begin
        data_out[DATA_WIDTH + i] = parity_bits[i];
    end
end

endmodule