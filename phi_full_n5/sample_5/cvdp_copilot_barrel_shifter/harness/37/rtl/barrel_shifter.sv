
module barrel_shifter #(parameter DATA_WIDTH = 16, SHIFT_BITS_WIDTH = 4) (
    input [DATA_WIDTH-1:0] data_in,
    input [SHIFT_BITS_WIDTH-1:0] shift_bits,
    input rotate_left_right,
    input left_right,
    output reg [DATA_WIDTH-1:0] data_out
);

    always @(data_in, shift_bits, rotate_left_right, left_right) begin
        case (rotate_left_right)
           1'b0: begin
               if (left_right) begin
                   data_out = (data_in << shift_bits) & {DATA_WIDTH{1'b0}};
               end else begin
                   data_out = (data_in >> shift_bits) & {DATA_WIDTH{1'b0}};
               end
            end
           1'b1: begin
               if (left_right) begin
                   data_out = {data_in[DATA_WIDTH-shift_bits_width:0] << (shift_bits_width-1), data_in[DATA_WIDTH-1:shift_bits_width]} << shift_bits_width;
               end else begin
                   data_out = {data_in[shift_bits_width-1:0] >> (shift_bits_width-1), data_in[0:shift_bits_width]} >> shift_bits_width;
               end
            end
        endcase
    end

endmodule
