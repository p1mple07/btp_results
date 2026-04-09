module SR_flipflop(
    input i_S,
    input i_R,
    input i_clk,
    input i_rst_b,
    output reg o_Q,
    output reg o_Q_b
);

    // Asynchronous active-low reset
    always @(posedge i_clk or negedge i_rst_b)
        if (!i_rst_b)
        begin
            o_Q <= 1'b0;
            o_Q_b <= 1'b1;
        end
        else
        begin
            // Synchronous operation on rising clock edge
            if (i_S && !i_R)
                o_Q <= 1'b1;
            else if (!i_S && i_R)
                o_Q <= 1'b0;
            else
                o_Q <= o_Q;
        end

endmodule
