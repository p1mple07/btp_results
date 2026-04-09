module nbit_swizzling #(
    parameter DATA_WIDTH = 64
)(
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output [DATA_WIDTH-1:0] data_out
);

always @(*) begin
    if (sel == 0) begin
        data_out = reverse(data_in);
    end else if (sel == 1) begin
        data_out[0:DATA_WIDTH/2 - 1] = reverse(data_in[0:DATA_WIDTH/2 - 1]);
        data_out[DATA_WIDTH/2 : DATA_WIDTH - 1] = reverse(data_in[DATA_WIDTH/2 : DATA_WIDTH - 1]);
    end else if (sel == 2) begin
        data_out[0:DATA_WIDTH/4 - 1] = reverse(data_in[0:DATA_WIDTH/4 - 1]);
        data_out[DATA_WIDTH/4 : DATA_WIDTH/2 - 1] = reverse(data_in[DATA_WIDTH/4 : DATA_WIDTH/2 - 1]);
        data_out[DATA_WIDTH/2 : 3*DATA_WIDTH/4 - 1] = reverse(data_in[DATA_WIDTH/2 : 3*DATA_WIDTH/4 - 1]);
        data_out[3*DATA_WIDTH/4 : DATA_WIDTH - 1] = reverse(data_in[3*DATA_WIDTH/4 : DATA_WIDTH - 1]);
    end else if (sel == 3) begin
        data_out[0:DATA_WIDTH/8 - 1] = reverse(data_in[0:DATA_WIDTH/8 - 1]);
        data_out[DATA_WIDTH/8 : DATA_WIDTH/4 - 1] = reverse(data_in[DATA_WIDTH/8 : DATA_WIDTH/4 - 1]);
        data_out[DATA_WIDTH/4 : 3*DATA_WIDTH/8 - 1] = reverse(data_in[DATA_WIDTH/4 : 3*DATA_WIDTH/8 - 1]);
        data_out[3*DATA_WIDTH/8 : 7*DATA_WIDTH/8 - 1] = reverse(data_in[3*DATA_WIDTH/8 : 7*DATA_WIDTH/8 - 1]);
        data_out[7*DATA_WIDTH/8 : DATA_WIDTH - 1] = reverse(data_in[7*DATA_WIDTH/8 : DATA_WIDTH - 1]);
    end else
        data_out = data_in;
end

endmodule
