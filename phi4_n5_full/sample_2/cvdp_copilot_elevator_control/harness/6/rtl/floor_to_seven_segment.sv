module floor_to_seven_segment (
    input [3:0] floor,
    output reg [6:0] seven_seg_out
);

always @(*) begin
    case(floor)
        4'd0: seven_seg_out = 7'b1111110; // 0: a, b, c, d, e, f
        4'd1: seven_seg_out = 7'b0110000; // 1: b, c
        4'd2: seven_seg_out = 7'b1101101; // 2: a, b, d, e, g
        4'd3: seven_seg_out = 7'b1111001; // 3: a, b, c, d, g
        4'd4: seven_seg_out = 7'b0110011; // 4: b, c, f, g
        4'd5: seven_seg_out = 7'b1011011; // 5: a, c, d, f, g
        4'd6: seven_seg_out = 7'b1011111; // 6: a, c, d, e, f, g
        4'd7: seven_seg_out = 7'b1110000; // 7: a, b, c
        4'd8: seven_seg_out = 7'b1111111; // 8: a, b, c, d, e, f, g
        4'd9: seven_seg_out = 7'b1111011; // 9: a, b, c, d, f, g
        default: seven_seg_out = 7'b0000000; // Blank for invalid floors
    endcase
end

endmodule