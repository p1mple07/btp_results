module nbit_swizzling #(parameter DATA_WIDTH = 64) (
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

    always_comb begin
        case (sel)
            2'b0: data_out = ~data_in;
            2'b1: begin
                DATA_WIDTH = DATA_WIDTH / 2;
                assign data_out = {(DATA_WIDTH/2)-1:0, ~data_in[DATA_WIDTH/2-1:0]};
                assign data_out = {data_out, ~data_in[DATA_WIDTH-DATA_WIDTH/2+1:0]};
            end
            2'b10: begin
                DATA_WIDTH = DATA_WIDTH / 4;
                assign data_out = {(DATA_WIDTH/4)-1:0, ~data_in[DATA_WIDTH/4-1:0]};
                assign data_out = {data_out, ~data_in[DATA_WIDTH/2-DATA_WIDTH/4:DATA_WIDTH/4-1]};
                assign data_out = {data_out, ~data_in[DATA_WIDTH-DATA_WIDTH/4:DATA_WIDTH/2-1]};
            end
            2'b11: begin
                DATA_WIDTH = DATA_WIDTH / 8;
                assign data_out = {(DATA_WIDTH/8)-1:0, ~data_in[DATA_WIDTH/8-1:0]};
                assign data_out = {data_out, ~data_in[DATA_WIDTH/4-DATA_WIDTH/8:DATA_WIDTH/8-1]};
                assign data_out = {data_out, ~data_in[DATA_WIDTH/2-DATA_WIDTH/8:DATA_WIDTH/4-1]};
                assign data_out = {data_out, ~data_in[DATA_WIDTH-DATA_WIDTH/8:DATA_WIDTH/2-1]};
            end
            default: data_out = data_in;
        endcase
    end

endmodule
