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
            o_Q    <= 1'b0;    // Reset Q to 0
            o_Q_b  <= 1'b1;    // Reset Q_b to 1 (inverted Q)
        end else begin
            if (i_J && ~i_K)
                o_Q <= 1'b1;    // Set Q when J=1, K=0
            else if (~i_J && i_K)
                o_Q <= 1'b0;    // Reset Q when J=0, K=1
            else if (i_J && i_K)
                o_Q <= ~o_Q;    // Toggle Q when J=1, K=1
            // When both i_J and i_K are low, hold the current state
            o_Q_b <= ~o_Q;     // Update complement of Q
        end
    end

endmodule