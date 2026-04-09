module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

integer i;
integer parity = 0;

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH-1-i];
            end
        end
        
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/2-1-i];
                data_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];
            end
        end
        
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/4-1-i];
                data_out[DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];
                data_out[DATA_WIDTH/2 + i]   = data_in[3*DATA_WIDTH/4-1-i];
                data_out[3*DATA_WIDTH/4 + i] = data_in[DATA_WIDTH-1-i];
            end
        end
        
        2'b11: begin
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/8-1-i];
                data_out[DATA_WIDTH/8 + i]   = data_in[DATA_WIDTH/4-1-i];
                data_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/8-1-i];
                data_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/2-1-i];
                data_out[DATA_WIDTH/2 + i]   = data_in[5*DATA_WIDTH/8-1-i];
                data_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i];
                data_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i];
                data_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];
            end
        end
        default: begin
            data_out = data_in;
        end
    endcase
end

    // Compute parity of all data_in bits
    parity = 0;
    for (int j = 0; j < DATA_WIDTH; j = j + 1) begin
        parity ^= data_in[j];
    end

    data_out[DATA_WIDTH-1] = parity;

endmodule
