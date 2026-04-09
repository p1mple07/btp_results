module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input        shift_mode,   // new input
    output reg [7:0] data_out
);

    always @(*) begin
        if (left_right) begin
            if (shift_mode == 0) begin
                data_out = data_in << shift_bits;
            end else begin
                data_out = { data_in[7], data_in[6:0] };
            end
        end else begin
            if (shift_mode == 0) begin
                data_out = data_in >> shift_bits;
            end else begin
                data_out = { data_in[7] << 1, data_in[6:0] };
            end
        end
    end

endmodule
