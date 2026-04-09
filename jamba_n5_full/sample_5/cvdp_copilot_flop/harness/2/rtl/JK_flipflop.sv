module JK_flipflop(
    input i_J,       // J input of the JK flip-flop
    input i_K,       // K input of the JK flip-flop
    input i_clk,     // Clock input
    input i_rst_b,   // Asynchronous reset, active low
    output reg o_Q,  // Q output
    output reg o_Q_b // Inverted Q output
);

    // Always block triggered on the rising edge of the clock or the falling edge of the reset
    always @(posedge i_clk or negedge i_rst_b) 
    begin
        if (!i_rst_b) // Reset is active
        begin
            o_Q <= 1'b0;   // Set Q to 0
            o_Q_b <= 1'b1; // Set Q_b to 1 (inverted Q)
        end
        else
        begin
            if (i_J == 1 && i_K == 0)
                o_Q = 1'b1;
            else if (i_J == 0 && i_K == 1)
                o_Q = 1'b0;
            else if (i_J == 1 && i_K == 1)
                o_Q = ~o_Q;
            else
                o_Q = o_Q;
        end
    end

endmodule
