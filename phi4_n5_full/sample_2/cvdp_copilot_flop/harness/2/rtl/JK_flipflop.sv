module JK_flipflop(
    input i_J,       // J input of the JK flip-flop
    input i_K,       // K input of the JK flip-flop
    input i_clk,     // Clock input
    input i_rst_b,   // Asynchronous reset, active low
    output reg o_Q,  // Q output
    output reg o_Q_b // Inverted Q output
);

    always @(posedge i_clk or negedge i_rst_b) begin
        if (!i_rst_b) begin
            o_Q   <= 1'b0;
            o_Q_b <= 1'b1;
        end else begin
            if (i_J && !i_K) begin
                o_Q   <= 1'b1;
                o_Q_b <= 1'b0;
            end else if (!i_J && i_K) begin
                o_Q   <= 1'b0;
                o_Q_b <= 1'b1;
            end else if (i_J && i_K) begin
                o_Q   <= ~o_Q;
                o_Q_b <= ~o_Q_b;
            end else begin
                // When both inputs are low, hold the previous state.
            end
        end
    end

endmodule