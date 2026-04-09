module barrel_shifter_8bit(
    input [7:0] data_in,
    input [2:0] shift_bits,
    input left_right,
    output reg [7:0] data_out
);

always @(*) begin
    if (left_right == 1) begin // Shift left
        data_out = {data_in[6:0], {shift_bits{1'b0}}};
    end else begin // Shift right
        data_out = {{shift_bits{1'b0}}, data_in[7:shift_bits]};
    end
end

endmodule