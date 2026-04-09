module nbit_swizzling #(parameter DATA_WIDTH = 64) (
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

    always_comb begin
        case (sel)
            0: data_out = {DATA_WIDTH{data_in[DATA_WIDTH-1:0]}};
            1: begin
                DATA_WIDTH = (DATA_WIDTH + 7) / 2;
                data_out = {{(DATA_WIDTH/2{data_in[DATA_WIDTH-1-(DATA_WIDTH/2)-1:(DATA_WIDTH-1-(DATA_WIDTH/2))])},
                             (DATA_WIDTH/2{data_in[(DATA_WIDTH/2):(DATA_WIDTH-1)]})}};
            end
            2: begin
                DATA_WIDTH = (DATA_WIDTH + 7) / 4;
                data_out = {{(DATA_WIDTH/4{data_in[DATA_WIDTH-1-(DATA_WIDTH/4)-1:(DATA_WIDTH-1-(DATA_WIDTH/4))])},
                             (DATA_WIDTH/4{data_in[(DATA_WIDTH/4):(DATA_WIDTH-1-(DATA_WIDTH/4))]})},
                             {(DATA_WIDTH/4{data_in[DATA_WIDTH-1-(DATA_WIDTH/2)-1:(DATA_WIDTH-1-(DATA_WIDTH/2))]})},
                             (DATA_WIDTH/4{data_in[(DATA_WIDTH/2):(DATA_WIDTH-1-(DATA_WIDTH/2))]})}};
            end
            3: begin
                DATA_WIDTH = (DATA_WIDTH + 7) / 8;
                data_out = {{(DATA_WIDTH/8{data_in[DATA_WIDTH-1-(DATA_WIDTH/8)-1:(DATA_WIDTH-1-(DATA_WIDTH/8))]})},
                             (DATA_WIDTH/8{data_in[(DATA_WIDTH/8):(DATA_WIDTH-1-(DATA_WIDTH/8))]})},
                             {(DATA_WIDTH/8{data_in[DATA_WIDTH-1-(DATA_WIDTH/4)-1:(DATA_WIDTH-1-(DATA_WIDTH/4))]})},
                             (DATA_WIDTH/8{data_in[(DATA_WIDTH/4):(DATA_WIDTH-1-(DATA_WIDTH/4))]})},
                             {(DATA_WIDTH/8{data_in[DATA_WIDTH-1-(DATA_WIDTH/2)-1:(DATA_WIDTH-1-(DATA_WIDTH/2))]})},
                             (DATA_WIDTH/8{data_in[(DATA_WIDTH/2):(DATA_WIDTH-1-(DATA_WIDTH/2))]})},
                             {(DATA_WIDTH/8{data_in[DATA_WIDTH-1-(DATA_WIDTH/8)-1:(DATA_WIDTH-1-(DATA_WIDTH/8))]})},
                             (DATA_WIDTH/8{data_in[(DATA_WIDTH/8):(DATA_WIDTH-1-(DATA_WIDTH/8))]})},
                             {(DATA_WIDTH/8{data_in[DATA_WIDTH-1-(DATA_WIDTH/4)-1:(DATA_WIDTH-1-(DATA_WIDTH/4))]})},
                             (DATA_WIDTH/8{data_in[(DATA_WIDTH/4):(DATA_WIDTH-1-(DATA_WIDTH/4))]})}};
        default: data_out = data_in;
        endcase
    end
endmodule
