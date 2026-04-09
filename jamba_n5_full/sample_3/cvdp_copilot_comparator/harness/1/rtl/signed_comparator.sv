module signed_unsigned_comparator#(
    parameter WIDTH = 5
) (
    input wire [WIDTH-1:0] i_A,
    input wire [WIDTH-1:0] i_B,
    input wire i_enable,
    input wire i_mode,
    output reg o_greater,
    output reg o_less,
    output reg o_equal
);

    localparam bool signed_mode = i_mode == 1;

    always @(*) begin
        if (i_enable) begin
            if (signed_mode) begin
                // Signed comparison logic
                assign o_greater = ((i_A[WIDTH-1] > 0) && (i_B[WIDTH-1] < 0)) ? 1 : ( ((i_A[WIDTH-1] < 0) && (i_B[WIDTH-1] > 0)) ? 1 : 0 );
                assign o_less = ((i_A[WIDTH-1] < 0) && (i_B[WIDTH-1] > 0)) ? 1 : ( ((i_A[WIDTH-1] > 0) && (i_B[WIDTH-1] < 0)) ? 1 : 0 );
                assign o_equal = (i_A == i_B);
            end
            else begin
                // Magnitude mode: unsigned
                assign o_greater = i_A > i_B;
                assign o_less = i_A < i_B;
                assign o_equal = i_A == i_B;
            end
        end else begin
            o_greater = 0;
            o_less = 0;
            o_equal = 0;
        end
    end

endmodule
