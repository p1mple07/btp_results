module barrel_shifter_8bit (
    input wire [7:0] data_in,
    input wire [2:0] shift_bits,
    input wire left_right,
    output reg [7:0] data_out
);

always @(*) begin
    data_out = left_right ? (data_in << shift_bits) : (data_in >> shift_bits);
end

endmodule
