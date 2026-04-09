module barrel_shifter_8bit(
    input [7:0] data_in,
    input [2:0] shift_bits,
    input left_right,
    output reg [7:0] data_out
);

    always @(data_in, shift_bits, left_right) begin
        case ({shift_bits, left_right})
            3'b000: data_out = data_in;
            3'b001: data_out = {data_in[6:0], 1'b0};
            3'b010: data_out = {1'b0, data_in[6:1]};
            3'b011: data_out = {data_in[5:0], 1'b0};
            3'b100: data_out = {1'b0, data_in[7:2]};
            3'b101: data_out = data_in;
            3'b110: data_out = {data_in[1:0], 1'b0};
            3'b111: data_out = data_in;
        endcase
    end

endmodule
