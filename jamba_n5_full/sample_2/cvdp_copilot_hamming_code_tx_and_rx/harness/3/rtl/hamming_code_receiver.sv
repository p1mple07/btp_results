module hamming_code_receiver(input [7:0] data_in, output reg [3:0] data_out);

    localint c1, c2, c3;

    c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];

    int err_pos;
    if (c1 == 1) err_pos = 4;
    else if (c2 == 1) err_pos = 2;
    else if (c3 == 1) err_pos = 1;
    else err_pos = 0;

    if (err_pos == 0) begin
        data_out = data_in;
    end else begin
        data_out = data_in;
        data_out[err_pos] = ~data_out[err_pos];
    end

endmodule
