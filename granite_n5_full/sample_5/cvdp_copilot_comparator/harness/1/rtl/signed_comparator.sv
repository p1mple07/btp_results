module signed_unsigned_comparator #(
    parameter WIDTH = 5
)(
    input wire [WIDTH-1:0] i_A,
    input wire [WIDTH-1:0] i_B,
    input wire i_enable,
    input wire i_mode,
    output reg o_greater,
    output reg o_less,
    output reg o_equal
);

always @(*) begin
    case(i_mode)
        1'b1: begin
            if ((i_A[WIDTH-1] == 1) && (i_B[WIDTH-1] == 0)) begin
                o_greater <= 1;
                o_less <= 0;
                o_equal <= 0;
            end else if ((i_A[WIDTH-1] == 1) && (i_B[WIDTH-1] == 1)) begin
                o_greater <= 0;
                o_less <= 1;
                o_equal <= 0;
            end else if ((i_A[WIDTH-1] == 0) && (i_B[WIDTH-1] == 0)) begin
                o_greater <= 0;
                o_less <= 0;
                o_equal <= (i_A >= i_B)? 1 : 0;
            end
        end
        1'b0: begin
            if (i_A >= i_B) begin
                o_greater <= 1;
                o_less <= 0;
                o_equal <= 0;
            end else begin
                o_greater <= 0;
                o_less <= 1;
                o_equal <= 0;
            end
        end
        default: begin
            o_greater <= 0;
            o_less <= 0;
            o_equal <= 0;
        end
    endcase
end

assign o_greater = (i_enable)? o_greater : 1'b0;
assign o_less = (i_enable)? o_less : 1'b0;
assign o_equal = (i_enable)? o_equal : 1'b0;

endmodule