module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    output reg [7:0] data_out
);

    always @(*) begin
        if (left_right) begin
            // Perform left shift
            data_out = data_in << shift_bits;
        else begin
            // Perform right shift
            data_out = data_in >> shift_bits;
        end
    end

    // Additional logic to handle underflow in right shift
    if (!left_right && data_in < 8'h80000000) begin
        data_out = 0;
    end
endmodule