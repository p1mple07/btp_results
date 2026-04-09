/*
 * Module: floor_to_seven_segment
 * Description: Converts a single-digit floor number (0-9) into a 7-segment display encoding.
 *              The output seven_seg_out[6:0] represents segments a-g, where a is MSB and g is LSB.
 *              For invalid floors, the display remains blank (all segments off).
 */
module floor_to_seven_segment #(
    parameter WIDTH = 4  // Width of the floor input (should be at least 4 bits for 0-9)
)(
    input wire [WIDTH-1:0] floor,
    output reg [6:0] seven_seg_out
);

always @(*) begin
    if (floor < 10) begin
        case (floor)
            4'd0: seven_seg_out = 7'b1111110; // 0
            4'd1: seven_seg_out = 7'b0110000; // 1
            4'd2: seven_seg_out = 7'b1101101; // 2
            4'd3: seven_seg_out = 7'b1111001; // 3
            4'd4: seven_seg_out = 7'b0011011; // 4
            4'd5: seven_seg_out = 7'b1011011; // 5
            4'd6: seven_seg_out = 7'b1011111; // 6
            4'd7: seven_seg_out = 7'b1110000; // 7
            4'd8: seven_seg_out = 7'b1111111; // 8
            4'd9: seven_seg_out = 7'b1111011; // 9
            default: seven_seg_out = 7'b0000000;
        endcase
    end else begin
        seven_seg_out = 7'b0000000; // Blank for invalid floor
    end
end

endmodule
