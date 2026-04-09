module takes an 8-bit input vector "in" where in[7] has the highest priority
 * and in[0] has the lowest priority. The output "out" is a 3-bit binary code representing
 * the index of the highest active input line.
 *
 * Priority mapping:
 *   in[7] -> 3'b111
 *   in[6] -> 3'b110
 *   in[5] -> 3'b101
 *   in[4] -> 3'b100
 *   in[3] -> 3'b011
 *   in[2] -> 3'b010
 *   in[1] -> 3'b001
 *   in[0] -> 3'b000
 *
 * If no input is active (all zeros), the output defaults to 3'b000.
 */

module priority_encoder_8x3(
    input  [7:0] in,
    output reg [2:0] out
);

    always @(*) begin
        // Default: if no input is active, output is 3'b000.
        out = 3'b000;
        if (in[7])
            out = 3'b111;
        else if (in[6])
            out = 3'b110;
        else if (in[5])
            out = 3'b101;
        else if (in[4])
            out = 3'b100;
        else if (in[3])
            out = 3'b011;
        else if (in[2])
            out = 3'b010;
        else if (in[1])
            out = 3'b001;
        // in[0] is already handled by the default assignment (3'b000)
    end

endmodule