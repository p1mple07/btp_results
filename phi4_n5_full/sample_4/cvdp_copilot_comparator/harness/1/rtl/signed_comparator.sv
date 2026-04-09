module signed_unsigned_comparator #(parameter WIDTH = 5)(
    input  logic [WIDTH-1:0] i_A,
    input  logic [WIDTH-1:0] i_B,
    input  logic             i_enable,
    input  logic             i_mode,      // High = signed mode, Low = magnitude mode
    output logic             o_greater,   // High when i_A > i_B
    output logic             o_less,      // High when i_A < i_B
    output logic             o_equal      // High when i_A == i_B
);

    always_comb begin
        // When disabled, all outputs are low.
        if (!i_enable) begin
            o_greater = 1'b0;
            o_less    = 1'b0;
            o_equal   = 1'b0;
        end else begin
            if (i_mode) begin
                // Signed mode: interpret inputs as signed integers.
                if ($signed(i_A) > $signed(i_B)) begin
                    o_greater = 1'b1;
                    o_less    = 1'b0;
                    o_equal   = 1'b0;
                end else if ($signed(i_A) < $signed(i_B)) begin
                    o_greater = 1'b0;
                    o_less    = 1'b1;
                    o_equal   = 1'b0;
                end else begin
                    o_greater = 1'b0;
                    o_less    = 1'b0;
                    o_equal   = 1'b1;
                end
            end else begin
                // Magnitude mode: treat inputs as unsigned.
                if (i_A > i_B) begin
                    o_greater = 1'b1;
                    o_less    = 1'b0;
                    o_equal   = 1'b0;
                end else if (i_A < i_B) begin
                    o_greater = 1'b0;
                    o_less    = 1'b1;
                    o_equal   = 1'b0;
                end else begin
                    o_greater = 1'b0;
                    o_less    = 1'b0;
                    o_equal   = 1'b1;
                end
            end
        end
    end

endmodule