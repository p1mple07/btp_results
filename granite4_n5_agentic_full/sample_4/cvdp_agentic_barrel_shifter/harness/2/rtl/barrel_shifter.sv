module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input        shift_mode,
    output reg [7:0] data_out
);

    always @(*) begin
        case ({shift_mode, left_right})
            2'b00: data_out <= {shift_bits{1'b0}}, data_in};
            2'b01: data_out <= data_in >>> shift_bits;
            2'b10: data_out <= {{(shift_bits+1){1'b0}}, data_in[7:shift_bits]};
            2'b11: data_out <= data_in;
        endcase
    end

endmodule