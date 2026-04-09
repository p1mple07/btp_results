module JK_flipflop(
    input i_J,       // J input of the JK flip-flop
    input i_K,       // K input of the JK flip-flop
    input i_clk,     // Clock input
    input i_rst_b,   // Asynchronous reset, active low
    output reg o_Q,  // Q output
    output reg o_Q_b // Inverted Q output
);

    // Always block triggered on the rising edge of the clock or the falling edge of the reset.
    // This ensures asynchronous reset behavior and proper clocked operations.
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) // Asynchronous reset active (low)
        begin
            o_Q   <= 1'b0;   // Force output Q to low
            o_Q_b <= 1'b1;   // Force complement output Q_b to high
        end
        else
        begin
            // Synchronous operation based on i_J and i_K inputs.
            if (i_J && !i_K)
                o_Q <= 1'b1; // Set Q to high when J=1 and K=0
            else if (!i_J && i_K)
                o_Q <= 1'b0; // Reset Q to low when J=0 and K=1
            else if (i_J && i_K)
                o_Q <= ~o_Q; // Toggle Q when both J and K are high
            // If both i_J and i_K are low, hold the previous state (no assignment needed)

            // o_Q_b is always the complement of o_Q
            o_Q_b <= ~o_Q;
        end
    end

endmodule