module hamming_code_receiver(
    input  logic [7:0] data_in,
    output logic [3:0] data_out
);

    // Calculate syndrome bits for even parity error detection
    // c3: XOR of bits at positions 1, 3, 5, and 7
    logic c3;
    assign c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];

    // c2: XOR of bits at positions 2, 3, 6, and 7
    logic c2;
    assign c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];

    // c1: XOR of bits at positions 4, 5, 6, and 7
    logic c1;
    assign c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

    // Combine syndrome bits into a 3-bit value
    logic [2:0] syndrome;
    assign syndrome = {c1, c2, c3};

    // Create a corrected version of the 8-bit input.
    // The redundant bit at position 0 is not corrected.
    logic [7:0] corrected_data;

    // Error detection and correction:
    // If syndrome != 3'b000, an error is detected in one of the 7-bit Hamming code (data_in[7:1]).
    // The syndrome value (ranging 1 to 7) indicates the position of the erroneous bit.
    always_comb begin
        corrected_data = data_in; // default: pass through unchanged
        if (syndrome != 3'b000) begin
            // Flip the bit at the position indicated by syndrome (only for bits 1 to 7)
            corrected_data[syndrome] = ~corrected_data[syndrome];
        end
    end

    // Map the corrected data bits to the output.
    // According to the specification, data bits are at positions:
    //   7 -> Data bit 4 (MSB)
    //   6 -> Data bit 3
    //   5 -> Data bit 2
    //   3 -> Data bit 1
    assign data_out[3] = corrected_data[7];
    assign data_out[2] = corrected_data[6];
    assign data_out[1] = corrected_data[5];
    assign data_out[0] = corrected_data[3];

endmodule