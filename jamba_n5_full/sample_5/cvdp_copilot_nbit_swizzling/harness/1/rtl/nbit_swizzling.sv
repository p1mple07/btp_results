module nbit_swizzling #(
    parameter DATA_WIDTH = 64
) (
    input logic [DATA_WIDTH-1:0] data_in,
    input logic sel,
    output logic [DATA_WIDTH-1:0] data_out
);

always @(*) begin
    if (sel == 0) begin
        data_out = data_in;
    end else if (sel == 1) begin
        logic [DATA_WIDTH/2-1:0] half1, half2;
        half1 = data_in[0:(DATA_WIDTH/2)];
        half2 = data_in[(DATA_WIDTH/2):];
        data_out = reverse(half1) + reverse(half2);
    end else if (sel == 2) begin
        logic [DATA_WIDTH/4-1:0] quarter1, quarter2, quarter3, quarter4;
        quarter1 = data_in[0:(DATA_WIDTH/4)];
        quarter2 = data_in[(DATA_WIDTH/4):(DATA_WIDTH/2)];
        quarter3 = data_in[(DATA_WIDTH/2):(3*DATA_WIDTH/4)];
        quarter4 = data_in[(3*DATA_WIDTH/4):];
        data_out = reverse(quarter1) + reverse(quarter2) + reverse(quarter3) + reverse(quarter4);
    end else if (sel == 3) begin
        logic [DATA_WIDTH/8-1:0] eighth1, eighth2, eighth3, eighth4, eighth5, eighth6, eighth7, eighth8;
        eighth1 = data_in[0:(DATA_WIDTH/8)];
        eighth2 = data_in[(DATA_WIDTH/8):(DATA_WIDTH/4)];
        eighth3 = data_in[(DATA_WIDTH/4):(DATA_WIDTH/2)];
        eighth4 = data_in[(DATA_WIDTH/2):(3*DATA_WIDTH/8)];
        eighth5 = data_in[(3*DATA_WIDTH/8):(7*DATA_WIDTH/8)];
        eighth6 = data_in[(7*DATA_WIDTH/8):(15*DATA_WIDTH/8)];
        eighth7 = data_in[(15*DATA_WIDTH/8):(31*DATA_WIDTH/16)];
        eighth8 = data_in[(31*DATA_WIDTH/16):];
        data_out = reverse(eighth1) + reverse(eighth2) + reverse(eighth3) + reverse(eighth4) + reverse(eighth5) + reverse(eighth6) + reverse(eighth7) + reverse(eighth8);
    end
end

endmodule
