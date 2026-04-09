module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

integer i;

always @(*) begin
    int parity = 0;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
        parity ^= data_in[i];
    end

    data_out = (DATA_WIDTH > 0) ? (parity << (DATA_WIDTH-1)) | data_in : 0;

end

endmodule
