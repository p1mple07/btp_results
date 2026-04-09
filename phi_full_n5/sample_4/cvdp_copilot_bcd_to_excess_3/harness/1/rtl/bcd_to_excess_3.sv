module bcd_to_excess_3(
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error
);

    // Excess-3 calculation for valid BCD inputs
    always @ (bcd) begin
        case (bcd)
            4'b0000: excess3 = 4'b0111; // 0 + 3
            4'b0001: excess3 = 4'b1000; // 1 + 3
            4'b0010: excess3 = 4'b1001; // 2 + 3
            4'b0011: excess3 = 4'b1010; // 3 + 3
            4'b0100: excess3 = 4'b1011; // 4 + 3
            4'b0101: excess3 = 4'b1100; // 5 + 3
            4'b0110: excess3 = 4'b1101; // 6 + 3
            4'b0111: excess3 = 4'b1110; // 7 + 3
            4'b1000: excess3 = 4'b0001; // 8 + 3
            4'b1001: excess3 = 4'b0010; // 9 + 3
            default: begin
                excess3 = 4'b0000; // Invalid BCD input, set Excess-3 to 0
                error = 1; // Assert error flag
            end
        endcase
    end

endmodule
