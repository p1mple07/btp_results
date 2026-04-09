module nbit_swizzling #(parameter DATA_WIDTH = 64) (
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

    // Define internal signals for bit reversal
    logic [DATA_WIDTH/2-1:0] bit_array1, bit_array2, bit_array4, bit_array8;

    // Bit reversal logic
    always_comb begin
        case (sel)
            0: data_out = {bit_array8[DATA_WIDTH/8-1:0], bit_array8[DATA_WIDTH/8*2-1:DATA_WIDTH/4], bit_array8[DATA_WIDTH/4*2-1:DATA_WIDTH/2], bit_array8[DATA_WIDTH/2*2-1:DATA_WIDTH*3/4], bit_array8[DATA_WIDTH*3/4*2-1:DATA_WIDTH*5/8], bit_array8[DATA_WIDTH*5/8*2-1:DATA_WIDTH*6/8], bit_array8[DATA_WIDTH*6/8*2-1:DATA_WIDTH*7/8], bit_array8[DATA_WIDTH*7/8*2-1:DATA_WIDTH*8/8], data_in};
            1: begin
                bit_array1 = {bit_array8[DATA_WIDTH/8-1:0], bit_array8[DATA_WIDTH/8*2-1:DATA_WIDTH/4], bit_array8[DATA_WIDTH/4*2-1:DATA_WIDTH/2], bit_array8[DATA_WIDTH/2*2-1:DATA_WIDTH*3/4], bit_array8[DATA_WIDTH*3/4*2-1:DATA_WIDTH*5/8], bit_array8[DATA_WIDTH*5/8*2-1:DATA_WIDTH*6/8], bit_array8[DATA_WIDTH*6/8*2-1:DATA_WIDTH*7/8], bit_array8[DATA_WIDTH*7/8*2-1:DATA_WIDTH*8/8]};
                bit_array2 = {bit_array8[DATA_WIDTH/8*2-1:DATA_WIDTH/4], bit_array8[DATA_WIDTH/4*2-1:DATA_WIDTH/2], bit_array8[DATA_WIDTH/2*2-1:DATA_WIDTH*3/4], bit_array8[DATA_WIDTH*3/4*2-1:DATA_WIDTH*5/8], bit_array8[DATA_WIDTH*5/8*2-1:DATA_WIDTH*6/8], bit_array8[DATA_WIDTH*6/8*2-1:DATA_WIDTH*7/8], bit_array8[DATA_WIDTH*7/8*2-1:DATA_WIDTH*8/8]}
                data_out = {bit_array1, bit_array2};
            end
            2: begin
                bit_array1 = {bit_array8[DATA_WIDTH/16-1:0], bit_array8[DATA_WIDTH/16*2-1:DATA_WIDTH/8], bit_array8[DATA_WIDTH/8*2-1:DATA_WIDTH/4], bit_array8[DATA_WIDTH/4*2-1:DATA_WIDTH/2], bit_array8[DATA_WIDTH/2*2-1:DATA_WIDTH*3/4], bit_array8[DATA_WIDTH*3/4*2-1:DATA_WIDTH*5/8], bit_array8[DATA_WIDTH*5/8*2-1:DATA_WIDTH*6/8], bit_array8[DATA_WIDTH*6/8*2-1:DATA_WIDTH*7/8], bit_array8[DATA_WIDTH*7/8*2-1:DATA_WIDTH*8/8]}
                bit_array2 = {bit_array8[DATA_WIDTH/16*2-1:DATA_WIDTH/8], bit_array8[DATA_WIDTH/8*2-1:DATA_WIDTH/4], bit_array8[DATA_WIDTH/4*2-1:DATA_WIDTH/2], bit_array8[DATA_WIDTH/2*2-1:DATA_WIDTH*3/4], bit_array8[DATA_WIDTH*3/4*2-1:DATA_WIDTH*5/8], bit_array8[DATA_WIDTH*5/8*2-1:DATA_WIDTH*6/8], bit_array8[DATA_WIDTH*6/8*2-1:DATA_WIDTH*7/8], bit_array8[DATA_WIDTH*7/8*2-1:DATA_WIDTH*8/8]}
                data_out = {bit_array1, bit_array2};
            end
            3: begin
                bit_array1 = {bit_array8[DATA_WIDTH/32-1:0], bit_array8[DATA_WIDTH/32*2-1:DATA_WIDTH/16], bit_array8[DATA_WIDTH/16*2-1:DATA_WIDTH/8], bit_array8[DATA_WIDTH/8*2-1:DATA_WIDTH/4], bit_array8[DATA_WIDTH/4*2-1:DATA_WIDTH/2], bit_array8[DATA_WIDTH/2*2-1:DATA_WIDTH*3/4], bit_array8[DATA_WIDTH*3/4*2-1:DATA_WIDTH*5/8], bit_array8[DATA_WIDTH*5/8*2-1:DATA_WIDTH*6/8], bit_array8[DATA_WIDTH*6/8*2-1:DATA_WIDTH*7/8], bit_array8[DATA_WIDTH*7/8*2-1:DATA_WIDTH*8/8]}
                bit_array2 = {bit_array8[DATA_WIDTH/32*2-1:DATA_WIDTH/16], bit_array8[DATA_WIDTH/16*2-1:DATA_WIDTH/8], bit_array8[DATA_WIDTH/8*2-1:DATA_WIDTH/4], bit_array8[DATA_WIDTH/4*2-1:DATA_WIDTH/2], bit_array8[DATA_WIDTH/2*2-1:DATA_WIDTH*3/4], bit_array8[DATA_WIDTH*3/4*2-1:DATA_WIDTH*5/8], bit_array8[DATA_WIDTH*5/8*2-1:DATA_WIDTH*6/8], bit_array8[DATA_WIDTH*6/8*2-1:DATA_WIDTH*7/8], bit_array8[DATA_WIDTH*7/8*2-1:DATA_WIDTH*8/8]}
                data_out = {bit_array1, bit_array2};
            end
            default: data_out = data_in;
        endcase
    end

endmodule
