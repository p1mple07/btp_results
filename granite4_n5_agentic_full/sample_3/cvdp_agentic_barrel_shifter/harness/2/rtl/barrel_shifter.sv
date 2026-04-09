module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input        shift_mode,
    output reg [7:0] data_out
);

    always @(*) begin
        case (shift_mode)
            0: begin  // Logical Shift
                if (left_right) begin
                    data_out = {shift_bits{data_in[0]}}, data_in[7:shift_bits];
                end else begin
                    data_out = {data_in[6:0]}, shift_bits{1'b0};
                end
            end
            1: begin  // Arithmetic Shift
                if (left_right) begin
                    data_out = {shift_bits{data_in[0]}}, data_in[7:shift_bits];
                end else begin
                    data_out = {data_in[6:0]}, shift_bits{data_in[0]};
                end
            end
            default: begin
                $error("Invalid shift mode");
            end
        endcase
    end

endmodule