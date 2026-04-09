module hamming_code_receiver(
    input [7:0] data_in,
    output reg [3:0] data_out
);

    // Syndrome bits for error detection
    reg [2:0] c1, c2, c3;

    // Error detection logic
    always_comb begin
        c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    end

    // Error correction logic
    always_comb begin
        if (c1 == 3'b000 && c2 == 3'b000 && c3 == 3'b000) begin
            // No error detected
            data_out = data_in[7:4];
        end else if (c1 == 3'b001) begin
            // Error detected at position 1, invert it
            data_out = {data_in[7], ~data_in[1], data_in[6], data_in[4]};
        end else if (c2 == 3'b001) begin
            // Error detected at position 2, invert it
            data_out = {data_in[7], data_in[1], ~data_in[2], data_in[4]};
        end else if (c3 == 3'b001) begin
            // Error detected at position 3, invert it
            data_out = {data_in[7], data_in[1], data_in[2], ~data_in[3]};
        end
    end

endmodule
