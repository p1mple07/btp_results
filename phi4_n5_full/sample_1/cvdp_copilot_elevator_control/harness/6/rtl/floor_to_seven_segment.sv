module floor_to_seven_segment (
    input wire [$clog2(10)-1:0] current_floor, // current floor (0-9)
    output wire [6:0] seven_seg_out          // seven-segment display output (a-g segments, a is MSB, g is LSB)
);

always @(*) begin
    case(current_floor)
        4'd0: seven_seg_out = 7'b1111110; // segments a, b, c, d, e, f lit; g off
        4'd1: seven_seg_out = 7'b0110000; // segments b, c lit
        4'd2: seven_seg_out = 7'b1101101; // segments a, b, d, e, g lit
        4'd3: seven_seg_out = 7'b1111001; // segments a, b, c, d, g lit
        4'd4: seven_seg_out = 7'b0110011; // segments b, c, f, g lit
        4'd5: seven_seg_out = 7'b1011011; // segments a, c, d, f, g lit
        4'd6: seven_seg_out = 7'b1011111; // segments a, c, d, e, f, g lit
        4'd7: seven_seg_out = 7'b1110000; // segments a, b, c lit
        4'd8: seven_seg_out = 7'b1111111; // all segments lit
        4'd9: seven_seg_out = 7'b1111011; // segments a, b, c, d, f, g lit
        default: seven_seg_out = 7'b0000000; // blank for invalid floor
    endcase
end

endmodule