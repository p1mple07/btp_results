module hamming_code_receiver(
    input [7:0] data_in,
    output reg [3:0] data_out
);

    // Syndrome bits for error detection
    logic c1, c2, c3;

    // Error detection logic
    always_comb begin
        c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    end

    // Error correction logic
    always_comb begin
        if ({c1, c2, c3} == 3'b000) begin
            // No error detected
            data_out = data_in;
        end else begin
            // Single-bit error detected, correct it
            case ({c1, c2, c3})
                3'b001: data_out = {data_in[6], data_in[6], data_in[6], data_in[6]};
                3'b010: data_out = {data_in[5], data_in[5], data_in[5], data_in[5]};
                3'b011: data_out = {data_in[4], data_in[4], data_in[4], data_in[4]};
                3'b100: data_out = {data_in[3], data_in[3], data_in[3], data_in[3]};
                3'b101: data_out = {data_in[2], data_in[2], data_in[2], data_in[2]};
                3'b110: data_out = {data_in[1], data_in[1], data_in[1], data_in[1]};
            endcase
        end
    end

endmodule
