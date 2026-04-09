module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input        shift_mode,   // new signal: 0 for logical, 1 for arithmetic
    output reg [7:0] data_out
);

    localparam shift_mode = shift_mode;
    localparam is_arith = (shift_mode == 1);

    always @(*) begin
        if (left_right) begin
            if (is_arith) begin
                // Arithmetic left shift: replicate the sign bit (MSB)
                data_out = {[6:0] data_in, [7:8] (data_in[7] == 1 ? 1'b1 : 1'b0)};
            end else begin
                data_out = data_in << shift_bits;
            end
        end else begin
            if (is_arith) begin
                // Arithmetic right shift: replicate the sign bit into vacated MSB positions
                data_out = {[7:8] (data_in[7] == 1 ? 1'b1 : 1'b0), data_in[0:7]};
            end else begin
                data_out = data_in >> shift_bits;
            end
        end
    end

endmodule
