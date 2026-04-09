module bcd_to_excess_3(
    input [3:0] bcd,
    output [3:0] excess3,
    output error
);

    // Valid BCD is 0-9 (0000-1001)
    // Invalid BCD is 10-15 (1010-1111)
    // When invalid, set error to 1 and output to 0

    // Check if bcd is valid
    // If bcd >= 1010, set error to 1
    error = (bcd & 1010) | (bcd & 1011) | (bcd & 1110) | (bcd & 1111);

    // If valid, compute excess3 = bcd + 3
    // Implementing full adder for each bit
    // bit0: bcd[0] + 3bit0 (0) + carry_in
    // bit1: bcd[1] + 3bit1 (1) + carry_in
    // bit2: bcd[2] + 3bit2 (1) + carry_in
    // bit3: bcd[3] + 3bit3 (1) + carry_in

    // Implementing the adder logic
    // Using XOR for sum and AND for carry
    // Assuming carry_in is 0 initially
    // excess3[0] = bcd[0] ^ 0 (since 3's bit0 is 0)
    // excess3[1] = bcd[1] ^ 1 (since 3's bit1 is 1)
    // excess3[2] = bcd[2] ^ 1 (since 3's bit2 is 1)
    // excess3[3] = bcd[3] ^ 1 (since 3's bit3 is 1)
    // But also considering carry from previous bits

    // However, to implement the full adder correctly, we need to consider carry propagation
    // This is a simplified version without considering carry propagation
    // In a real implementation, a full adder would be needed for each bit

    // For the purpose of this example, assuming no carry beyond 4 bits
    // So, excess3 = bcd + 3 if valid, else 0

    // Implementing the adder
    // excess3[0] = bcd[0] ^ 0 (since 3's bit0 is 0)
    // excess3[1] = bcd[1] ^ 1 (since 3's bit1 is 1)
    // excess3[2] = bcd[2] ^ 1 (since 3's bit2 is 1)
    // excess3[3] = bcd[3] ^ 1 (since 3's bit3 is 1)
    // But this doesn't account for carry, so it's incorrect

    // Correct implementation requires full adder for each bit
    // This is a simplified example
    excess3 = bcd + 3;

    // If invalid, set excess3 to 0 and error to 1
    excess3 = error ? 4'b0000 : excess3;
    error = error;

endmodule