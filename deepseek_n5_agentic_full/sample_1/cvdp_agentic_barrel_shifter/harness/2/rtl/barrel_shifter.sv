module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input left_right,
    input clock,
    output reg [7:0] data_out
);

    always @(*) begin
        if (left_right) begin
            if (shift_mode) begin
                // Arithmetic Left Shift
                data_out = (data_in << shift_bits) & 8'hff;
            end else begin
                // Logical Left Shift
                data_out = (data_in << shift_bits) & 8'hff;
            end
        end else begin
            if (shift_mode) begin
                // Arithmetic Right Shift
                data_out = (data_in >> shift_bits) & 8'hff;
            end else begin
                // Logical Right Shift
                data_out = (data_in >> shift_bits) & 8'hff;
            end
        end
    end

endmodule