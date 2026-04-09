module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input        shift_mode,
    output reg [7:0] data_out
);

    always @(*) begin
        case (shift_mode)
            0: begin // Logical Shift
                if (left_right) begin
                    data_out <= {shift_bits{data_in[0]}}, data_in >> shift_bits;
                end else begin
                    data_out <= data_in << shift_bits, {shift_bits{data_in[7]}};
                end
            end
            1: begin // Arithmetic Shift
                if (left_right) begin
                    data_out <= {shift_bits{data_in[0]}}, data_in >> shift_bits;
                end else begin
                    data_out <= data_in << shift_bits;
                    if ((data_in[0] == 1) && (shift_bits > 0)) begin
                        data_out[0] = 1;
                    end
                end
            end
            default: begin
                data_out <= data_in;
            end
        endcase
    end

endmodule