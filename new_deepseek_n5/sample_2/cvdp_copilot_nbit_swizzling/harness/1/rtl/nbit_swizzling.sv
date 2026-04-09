module nbit_swizzling(
    parameter DATA_WIDTH = 64,
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output [DATA_WIDTH-1:0] data_out
);

    // Case 0: sel = 0, reverse entire input
    if (sel == 0) begin
        data_out = data_in;
        for (int i = 0; i < DATA_WIDTH; i++) begin
            data_out[i] = data_in[DATA_WIDTH-1-i];
        end
    // Case 1: sel = 1, reverse two halves
    else if (sel == 1) begin
        data_out = data_in;
        for (int i = 0; i < 32; i++) begin
            data_out[i] = data_in[63-i];
            data_out[63-i] = data_in[i];
        end
        for (int i = 0; i < 32; i++) begin
            data_out[32+i] = data_in[31-i];
            data_out[31-i] = data_in[32+i];
        end
    // Case 2: sel = 2, reverse four quarters
    else if (sel == 2) begin
        data_out = data_in;
        for (int i = 0; i < 16; i++) begin
            data_out[i] = data_in[63-i];
            data_out[63-i] = data_in[i];
        end
        for (int i = 0; i < 16; i++) begin
            data_out[16+i] = data_in[47-i];
            data_in[47-i] = data_in[16+i];
        end
        for (int i = 0; i < 16; i++) begin
            data_out[32+i] = data_in[31-i];
            data_in[31-i] = data_in[32+i];
        end
        for (int i = 0; i < 16; i++) begin
            data_out[48+i] = data_in[15-i];
            data_in[15-i] = data_in[48+i];
        end
    // Case 3: sel = 3, reverse eight octets
    else if (sel == 3) begin
        data_out = data_in;
        for (int i = 0; i < 8; i++) begin
            data_out[i] = data_in[63-i];
            data_in[63-i] = data_in[i];
        end
        for (int i = 0; i < 8; i++) begin
            data_out[8+i] = data_in[55-i];
            data_in[55-i] = data_in[8+i];
        end
        for (int i = 0; i < 8; i++) begin
            data_out[16+i] = data_in[47-i];
            data_in[47-i] = data_in[16+i];
        end
        for (int i = 0; i < 8; i++) begin
            data_out[24+i] = data_in[39-i];
            data_in[39-i] = data_in[24+i];
        end
        for (int i = 0; i < 8; i++) begin
            data_out[32+i] = data_in[31-i];
            data_in[31-i] = data_in[32+i];
        end
        for (int i = 0; i < 8; i++) begin
            data_out[40+i] = data_in[23-i];
            data_in[23-i] = data_in[40+i];
        end
        for (int i = 0; i < 8; i++) begin
            data_out[48+i] = data_in[15-i];
            data_in[15-i] = data_in[48+i];
        end
        for (int i = 0; i < 8; i++) begin
            data_out[56+i] = data_in[7-i];
            data_in[7-i] = data_in[56+i];
        end
    // Default case: output matches input
    else begin
        data_out = data_in;
    end

endmodule