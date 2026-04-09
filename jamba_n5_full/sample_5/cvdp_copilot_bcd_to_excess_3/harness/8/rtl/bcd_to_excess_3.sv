`timescale 1ns / 1ps

module bcd_to_excess_3 (
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error,
    output reg parity,
    output reg [1:0] error_code
);

    localparam u_en = $random; // Simulate random enable generation (optional)

    assign error_code = (enable) ? (bcd < 10) ? 2'b00 : 2'b01 : 2'b10;

    always @(posedge clk) begin
        if (~rst) begin
            excess3 <= 4'b0000;
            error <= 1'b0;
            parity <= 1'b0;
            error_code <= 2'b00;
        end else begin
            if (enable) begin
                if (bcd >= 0 && bcd <= 9) begin
                    // Convert BCD to excess3 using a case statement
                    case (bcd)
                        4'b0000: excess3 = 4'b0011;   // 0 decimal
                        4'b0001: excess3 = 4'b0100;   // 1 decimal
                        4'b0010: excess3 = 4'b0101;   // 2 decimal
                        4'b0011: excess3 = 4'b0110;   // 3 decimal
                        4'b0100: excess3 = 4'b0111;   // 4 decimal
                        4'b0101: excess3 = 4'b1000;   // 5 decimal
                        4'b0110: excess3 = 4'b1001;   // 6 decimal
                        4'b0111: excess3 = 4'b1010;   // 7 decimal
                        4'b1000: excess3 = 4'b1011;   // 8 decimal
                        4'b1001: excess3 = 4'b1100;   // 9 decimal
                        4'b1010: excess3 = 4'b1101;   // A hexadecimal
                        4'b1011: excess3 = 4'b1110;   // B hexadecimal
                        4'b1100: excess3 = 4'b1111;   // C hexadecimal
                        4'b1101: excess3 = 4'b1111;   // D hexadecimal
                        4'b1110: excess3 = 4'b1111;   // E hexadecimal
                        4'b1111: excess3 = 4'b1111;   // F hexadecimal
                    endcase
                end else begin
                    excess3 <= 4'b0000;
                    error <= 1'b1;
                    parity <= 1'b0;
                    error_code = 2'b01;
                end
            end else begin
                excess3 <= 4'b0000;
                error <= 1'b0;
                parity <= 1'b0;
                error_code <= 2'b00;
            end
        end
    end

endmodule
