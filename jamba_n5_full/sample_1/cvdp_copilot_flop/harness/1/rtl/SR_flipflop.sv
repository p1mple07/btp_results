module SR_flipflop(
    input i_S,
    input i_R,
    input i_clk,
    input i_rst_b,
    output reg o_Q,
    output reg o_Q_b
);

    // Always block triggered on the positive edge of the clock
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) {
            o_Q <= 1'b0;
            o_Q_b <= 1'b1;
        }
        else {
            if (i_S && i_R) begin
                o_Q <= 1'b0;
                o_Q_b <= 1'b1;
            }
            else {
                o_Q <= i_S;
                o_Q_b <= ~o_Q;
            }
        }
    end

endmodule
