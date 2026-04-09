// Polynomial selection based on mode
always_comb begin
    case (mode)
        4'b0000: feedback = lfsr[15] ^ lfsr[14]; // Mode 0: x^16 + x^15 + 1
        4'b0001: feedback = lfsr[15] ^ lfsr[13]; // Mode 1: x^16 + x^14 + 1
        4'b0010: feedback = lfsr[15] ^ lfsr[7] ^ lfsr[0]; // Mode 2: x^16 + x^8 + x + 1
        4'b0011: feedback = lfsr[15] ^ lfsr[8]; // Mode 3: x^16 + x^8 + 1
        4'b0100: feedback = lfsr[15] ^ lfsr[12] ^ lfsr[4]; // Mode 4: x^16 + x^13 + x^2 + 1
        4'b0101: feedback = lfsr[15] ^ lfsr[11]; // Mode 5: x^16 + x^12 + 1
        4'b0110: feedback = lfsr[15] ^ lfsr[3] ^ lfsr[0]; // Mode 6: x^16 + x^3 + x + 1
        4'b0111: feedback = lfsr[15] ^ lfsr[11] ^ lfsr[4]; // Mode 7: x^16 + x^11 + x^4 + 1
        default: feedback = lfsr[15]; // Default: x^16 + 1
    endcase
end