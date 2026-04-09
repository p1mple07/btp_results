module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input logic [WIDTH-1:0] i_A,
    input logic [WIDTH-1:0] i_B,
    input logic                i_enable,
    input logic                i_mode,
    output logic               o_greater,
    output logic               o_less,
    output logic               o_equal
);

    localparam signed_max = (1 << (WIDTH-1)) - 1;
    localparam signed_min = -(1 << (WIDTH-1));
    localparam mag_max = ((1 << (WIDTH-1)) - 1) << 1;
    localparam mag_min = -((1 << (WIDTH-1)) - 1) << 1;

    always_comb begin
        o_greater = 1'b0;
        o_less = 1'b0;
        o_equal = 1'b0;

        if(i_enable == 1'b1) begin
            if(i_mode == 1'b1) begin // Signed Mode
                if(i_A > signed_max || i_B > signed_max || i_A < signed_min || i_B < signed_min) begin
                    // Out of range for signed comparison
                end else begin
                    if(i_A > i_B) begin
                        o_greater = 1'b1;
                    end else if(i_A < i_B) begin
                        o_less = 1'b1;
                    end else begin
                        o_equal = 1'b1;
                    end
                end
            end else begin // Magnitude Mode
                if(i_A > mag_max || i_B > mag_max || i_A < mag_min || i_B < mag_min) begin
                    // Out of range for magnitude comparison
                end else begin
                    if(i_A > i_B) begin
                        o_greater = 1'b1;
                    end else if(i_A < i_B) begin
                        o_less = 1'b1;
                    end else begin
                        o_equal = 1'b1;
                    end
                end
            end
        end
    end

endmodule