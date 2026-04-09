module floor_to_seven_segment (
    input logic [3:0] floor,         // Input floor (0-9)
    output logic [6:0] seven_seg_out  // Seven-segment display output (a-g, MSB=a, LSB=g)
);

// Combinational seven-segment conversion
always @(*) begin
    case (floor)
        4'd0: seven_seg_out = 7'b1111110; // a, b, c, d, e, f lit (g off)
        4'd1: seven_seg_out = 7'b0010010; // b, c lit
        4'd2: seven_seg_out = 7'b1011011; // a, b, d, e, g lit
        4'd3: seven_seg_out = 7'b1011111; // a, b, c, d, g lit
        4'd4: seven_seg_out = 7'b0111010; // b, c, f, g lit
        4'd5: seven_seg_out = 7'b1101011; // a, c, d, f, g lit
        4'd6: seven_seg_out = 7'b1101111; // a, c, d, e, f, g lit
        4'd7: seven_seg_out = 7'b1010010; // a, b, c lit
        4'd8: seven_seg_out = 7'b1111111; // All segments lit
        4'd9: seven_seg_out = 7'b1111011; // a, b, c, d, f, g lit
        default: seven_seg_out = 7'b0000000; // Blank display for invalid floor
    endcase
end

endmodule