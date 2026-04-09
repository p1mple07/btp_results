module bcd_to_excess_3(
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error
);

    // Conversion logic
    always @ (bcd) begin
        case (bcd)
            4'b0000: excess3 = 4'b0111;
            4'b0001: excess3 = 4'b0110;
            4'b0010: excess3 = 4'b0101;
            4'b0011: excess3 = 4'b0010;
            4'b0100: excess3 = 4'b0001;
            4'b0101: excess3 = 4'b0110;
            4'b0110: excess3 = 4'b0101;
            4'b0111: excess3 = 4'b0010;
            4'b1000: excess3 = 4'b0001;
            4'b1001: excess3 = 4'b0110;
            4'b1010: excess3 = 4'b0101;
            4'b1011: excess3 = 4'b0010;
            4'b1100: excess3 = 4'b0001;
            4'b1101: excess3 = 4'b0110;
            4'b1110: excess3 = 4'b0101;
            4'b1111: excess3 = 4'b0010;
            default: begin
                excess3 = 4'b0000;
                error = 1'b1;
            end
        endcase
    end

endmodule
