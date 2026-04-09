// Module Name: bcd_to_excess_3
// Inputs: bcd (4 bits)
// Outputs: excess3 (4 bits), error (1 bit)

// Truth Table:
// bcd | excess3 | error
// 0000 | 0011     0
// 0001 | 0010     0
// 0010 | 0001     0
// 0011 | 0000     0
// 0100 | 0101     0
// 0101 | 0100     0
// 0110 | 0100     0
// 0111 | 0011     0
// 1000 | 1101     0
// 1001 | 1100     0
// 1010 | 0000     1
// 1011 | 0000     1
// 1100 | 0000     1
// 1101 | 0000     1
// 1110 | 0000     1
// 1111 | 0000     1

// Implementation:
output [3:0] excess3;
output error;

// Logic:
// Calculate excess3 by adding 3 to bcd
// error is 1 if bcd is invalid (10-15)
error = (bcd >> 3) & 1; // Check if bcd is 10 or higher
excess3 = bcd ^ (error << 3); // Add 3 to bcd, but set to 0 if error