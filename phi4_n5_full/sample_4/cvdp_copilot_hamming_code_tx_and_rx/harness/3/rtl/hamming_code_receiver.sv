module hamming_code_receiver(
    input  logic [7:0] data_in,
    output logic [3:0] data_out
);

    // Calculate syndrome bits for even parity check on data_in[7:1]
    // c3: XOR of bits at positions 1, 3, 5, and 7
    wire c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
    // c2: XOR of bits at positions 2, 3, 6, and 7
    wire c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    // c1: XOR of bits at positions 4, 5, 6, and 7
    wire c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

    // Syndrome combines the parity check results.
    // A syndrome of 3'b000 indicates that the error is in the redundant bit (data_in[0])
    // and no error exists in the 7-bit Hamming code.
    wire [2:0] syndrome = {c3, c2, c1};

    // Correct the error if detected (only correct bits in data_in[7:1])
    logic [7:0] corrected_data;
    always_comb begin
        corrected_data = data_in; // Default: no change
        if (syndrome != 3'b000) begin
            // Invert the erroneous bit at the position indicated by the syndrome.
            corrected_data[syndrome] = ~data_in[syndrome];
        end
    end

    // Map the corrected data bits to the output.
    // According to the specification, data bits are located at:
    // data_in[7] -> Data bit 4, data_in[6] -> Data bit 3,
    // data_in[5] -> Data bit 2, data_in[3] -> Data bit 1.
    assign data_out[3] = corrected_data[7];
    assign data_out[2] = corrected_data[6];
    assign data_out[1] = corrected_data[5];
    assign data_out[0] = corrected_data[3];

endmodule