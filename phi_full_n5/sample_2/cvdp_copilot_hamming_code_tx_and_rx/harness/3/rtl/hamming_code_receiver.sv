module hamming_code_receiver(
    input [7:0] data_in,
    output reg [3:0] data_out
);

    reg [2:0] c1, c2, c3;

    // Calculate parity bits
    always @(*) begin
        c1 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        c3 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    end

    // Determine if there is an error
    always @(*) begin
        case ({c1, c2, c3})
            3'b000: data_out = data_in[0]; // No error, pass through redundant bit
            3'b001: data_out = ~data_in[1]; // Invert bit at position 1
            3'b010: data_out = ~data_in[2]; // Invert bit at position 2
            3'b011: data_out = data_in[3]; // No error, pass through data bit
            3'b100: data_out = ~data_in[4]; // Invert bit at position 4
            3'b101: data_out = data_in[5]; // No error, pass through data bit
            3'b110: data_out = data_in[6]; // No error, pass through data bit
            3'b111: data_out = data_in[7]; // No error, pass through data bit
            default: data_out = data_in[7:3]; // No error, pass through data bits
        endcase
    end

endmodule