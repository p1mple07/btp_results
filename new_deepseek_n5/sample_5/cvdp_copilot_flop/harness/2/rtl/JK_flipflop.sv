module JK_flipflop(
    input i_J,       // J input of the JK flip-flop
    input i_K,       // K input of the JK flip-flop
    input i_clk,     // Clock input
    input i_rst_b,   // Asynchronous reset, active low
    output reg o_Q,  // Q output
    output reg o_Q_b // Inverted Q output
);

    // Edge triggering will allow to stop race condition and toggle Q when J,K =1,1.
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) // If reset is active (low)
        begin
            o_Q <= 1'b0;   // Set Q to 0
            o_Q_b <= 1'b1; // Set Q_b to 1 (inverted Q)
        end
        else
        begin
            if (i_J & i_K) // Both J and K are high
            begin
                o_Q <= !o_Q; // Toggle Q
            end
            else if (i_J) // J is high
            begin
                o_Q <= 1'b1; // Set Q to 1
            end
            else if (i_K) // K is high
            begin
                o_Q <= 1'b0; // Set Q to 0
            end
        end
    end

endmodule