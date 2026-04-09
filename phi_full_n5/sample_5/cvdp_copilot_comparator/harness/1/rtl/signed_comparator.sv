module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input wire [WIDTH-1:0] i_A,
    input wire [WIDTH-1:0] i_B,
    input wire i_enable,
    input wire i_mode,
    output reg o_greater,
    output reg o_less,
    output reg o_equal
);

    // When enabled, perform comparison based on mode
    always_comb begin
        if (i_enable) begin
            if (i_mode) begin
                // Signed mode: MSB is sign bit
                case (i_A[WIDTH-1], i_B[WIDTH-1]) :
                    when (i_A[WIDTH-1] == i_B[WIDTH-1]) begin
                        o_equal = 1'b1;
                        o_greater = 1'b0;
                        o_less = 1'b0;
                    end
                    when (i_A[WIDTH-1] > i_B[WIDTH-1]) begin
                        o_greater = 1'b1;
                        o_equal = 1'b0;
                        o_less = 1'b0;
                    end
                    when (i_A[WIDTH-1] < i_B[WIDTH-1]) begin
                        o_less = 1'b1;
                        o_equal = 1'b0;
                        o_greater = 1'b0;
                    end
                end
            end else begin
                // Magnitude mode: MSB is sign bit ignored
                case (i_A, i_B) :
                    when ((i_A & ~(1 << (WIDTH-1))) == (i_B & ~(1 << (WIDTH-1)))) begin
                        o_equal = 1'b1;
                        o_greater = 1'b0;
                        o_less = 1'b0;
                    end
                    when ((i_A & ~(1 << (WIDTH-1))) > (i_B & ~(1 << (WIDTH-1)))) begin
                        o_greater = 1'b1;
                        o_equal = 1'b0;
                        o_less = 1'b0;
                    end
                    when ((i_A & ~(1 << (WIDTH-1))) < (i_B & ~(1 << (WIDTH-1)))) begin
                        o_less = 1'b1;
                        o_equal = 1'b0;
                        o_greater = 1'b0;
                    end
                end
            end
        end else begin
            o_greater = 1'b0;
            o_less = 1'b0;
            o_equal = 1'b0;
        end
    end
endmodule
