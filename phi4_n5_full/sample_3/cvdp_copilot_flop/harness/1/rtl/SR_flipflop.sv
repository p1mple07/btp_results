module SR_flipflop(
    input i_S,        // Set input
    input i_R,        // Reset input
    input i_clk,      // Clock input
    input i_rst_b,    // Asynchronous active-low reset input
    output reg o_Q,   // Output Q
    output reg o_Q_b  // Inverted output Q
);

    // Always block triggered on the positive edge of the clock or asynchronous reset
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) // Asynchronous reset active-low
        begin
            o_Q   <= 1'b0;   // Force output Q to 0
            o_Q_b <= 1'b1;   // Force inverted output Q to 1
        end
        else
        begin
            // Synchronous operations on the rising edge of the clock
            if (i_S && !i_R)
            begin
                o_Q   <= 1'b1;   // Set output Q to 1
                o_Q_b <= 1'b0;   // Complement output Q
            end
            else if (!i_S && i_R)
            begin
                o_Q   <= 1'b0;   // Reset output Q to 0
                o_Q_b <= 1'b1;   // Complement output Q
            end
            else
            begin
                // Hold the previous state when both inputs are low
                o_Q   <= o_Q;
                o_Q_b <= o_Q_b;
            end
        end
    end

endmodule