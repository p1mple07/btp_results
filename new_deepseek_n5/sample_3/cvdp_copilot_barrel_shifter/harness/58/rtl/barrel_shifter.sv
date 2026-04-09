module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,
    input enable,
    input enable_parity,
    input left_right,
    input [data_width-1:0] mask,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    if (enable == 0) begin
        data_out = 0;
        error = 0;
        return;
    end

    case (mode)
        3'b000: begin
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = data_in >> shift_bits;
        end
        3'b001: begin
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = $signed(data_in) >>> shift_bits;
        end
        3'b010: begin
            if (left_right)
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
        end
        3'b011: begin
            if (left_right)
                data_out = (data_in << shift_bits) & mask;
            else
                data_out = (data_in >> shift_bits) & mask;
        end
        3'b100: begin
            if (left_right) begin
                data_out = data_in + shift_bits;
            else begin
                data_out = data_in - shift_bits;
            end
            if (data_out < 0) data_out += data_width;
        end
        3'b101: begin
            if (data_in == 0) begin
                data_out = 0;
                error = 0;
            else begin
                integer pos = -1;
                for (integer i = data_width-1; i >= 0; i--) begin
                    if ((data_in >> i) & 1) begin
                        pos = i;
                        break;
                    end
                end
                data_out = (data_in >> pos) << (data_width - pos - 1);
            end
        end
        3'b110: begin
            if (left_right) begin
                data_out = (data_in + shift_bits) % data_width;
            else begin
                data_out = (data_in - shift_bits) % data_width;
            end
        end
        default: begin
            data_out = 0;
            error = 1;
        end
    endcase
    if (enable_parity == 1) begin
        parity_out = data_out;
    else begin
        parity_out = 0;
    end
end

endmodule