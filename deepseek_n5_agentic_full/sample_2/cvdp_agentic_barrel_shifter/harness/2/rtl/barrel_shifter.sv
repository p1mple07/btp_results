module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input        shift_mode,
    output reg [7:0] data_out
);

    always @(*) begin
        if (left_right) begin
            data_out = data_in << shift_bits;
        else begin
            wire [7:0] data;
            if (shift_mode) begin
                // Arithmetic right shift
                data = ((data >> shift_bits) | (((data >> 7) & 1) << (7 - shift_bits)));
            else 
                // Logical right shift
                data = data >> shift_bits;
            end
            data_out = data;
        end
    end

endmodule