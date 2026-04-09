module bcd_to_excess_3(
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error
);

    // Constants for Excess-3 encoding
    parameter EXCESS3_VALUES = 4'b0110 | 4'b0111 | 4'b1000 | 4'b1001 | 4'b1010 | 4'b1011 | 4'b1100 | 4'b1101;

    // Function to check if the input is valid
    function [7:0] get_excess3(input [3:0] bcd);
        case (bcd)
            4'h10: return EXCESS3_VALUES[0];
            4'h11: return EXCESS3_VALUES[1];
            4'h12: return EXCESS3_VALUES[2];
            4'h13: return EXCESS3_VALUES[3];
            4'h14: return EXCESS3_VALUES[4];
            4'h15: return EXCESS3_VALUES[5];
            default: return 4'b0000;
        endcase
    endfunction

    // Conversion logic
    always @ (bcd) begin
        if (bcd < 4'h10 || bcd > 4'h15) begin
            excess3 = 4'h0000;
            error = 1;
        end else begin
            excess3 = get_excess3(bcd);
            error = 0;
        end
    end

endmodule
