module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4,
    parameter mode_width = 3
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input mode,
    input [data_width-1:0] mask,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    output reg [data_width-1:0] data_out,
    output reg error
);

    // Internal variables
    reg [data_width-1:0] shifted_data;
    reg [data_width-1:0] result;

    always @(*) begin
        case (mode)
            000: begin
                if (left_right)
                    shifted_data = data_in << shift_bits;
                else
                    shifted_data = data_in >> shift_bits;
                data_out = shifted_data;
            endbreak

            001: begin
                if (left_right)
                    shifted_data = data_in << shift_bits;
                else
                    shifted_data = $signed(data_in) >>> shift_bits;
                data_out = shifted_data;
            endbreak

            010: begin
                if (left_right)
                    shifted_data = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
                else
                    shifted_data = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
                data_out = shifted_data;
            endbreak

            011: begin
                if (left_right)
                    shifted_data = (data_in << shift_bits);
                else
                    shifted_data = (data_in >> shift_bits);
                result = shifted_data & mask;
                data_out = result;
            endbreak

            100: begin
                if (left_right)
                    shifted_data = (data_in << shift_bits);
                else
                    shifted_data = (data_in >> shift_bits);
                result = shifted_data ^ mask;
                data_out = result;
            endbreak

            default:
                error = 1;
                data_out = 0;
                break;
        endcase
    end
end

endmodule