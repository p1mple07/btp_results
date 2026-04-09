module hamming_code_receiver #(parameter DATA_WIDTH = 8) (
    input  wire [7:0] data_in,
    output reg [3:0] data_out
);

    reg [3:0] c1, c2, c3;

    c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];

    always @(*) begin
        data_out[3:0] = data_in[3:0];
        if (c1 || c2 || c3) begin
            if (c1) data_out[1] = ~data_in[1];
            else if (c2) data_out[2] = ~data_in[2];
            else if (c3) data_out[4] = ~data_in[4];
        end
    end

endmodule
