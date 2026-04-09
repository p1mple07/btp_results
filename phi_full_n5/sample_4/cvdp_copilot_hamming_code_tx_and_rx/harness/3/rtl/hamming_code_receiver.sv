module hamming_code_receiver(
    input [7:0] data_in,
    output reg [3:0] data_out
);

    // Syndrome bits for error detection
    logic c1, c2, c3;

    // Even parity checks
    always_comb begin
        // Calculate syndrome bits
        c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    end

    // Error correction logic
    always_comb begin
        // Check if error is detected
        if ((c1 | c2 | c3) != 3'b000) begin
            case (c1 | c2 | c3)
                3'b001: data_out = {data_in[1], data_in[2:0], 4'b1};
                3'b010: data_out = {data_in[3], data_in[4:2], 4'b1};
                3'b011: data_out = {data_in[5], data_in[6:4], 4'b1};
                3'b100: data_out = {data_in[7], data_in[6:5], 4'b1};
                3'b101: data_out = {data_in[4], data_in[5:3], 4'b1};
                3'b110: data_out = {data_in[6], data_in[7], 4'b1};
                default: data_out = data_in; // No error detected
            endcase
        end
    end

endmodule
