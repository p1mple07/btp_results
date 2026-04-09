module SR_flipflop(
    input i_S,        // Set input
    input i_R,        // Reset input
    input i_clk,      // Clock input
    input i_rst_b,    // Asynchronous active-low reset input
    output reg o_Q,   // Output Q
    output reg o_Q_b  // Complement of output Q
);

    // Always block triggered on the positive edge of the clock
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) // Asynchronous reset active-low
        begin
            o_Q <= 1'b0;  // Set output Q to 0
            o_Q_b <= 1'b1; // Set inverted output Q to 1
        end
        else
        begin
            if (i_S && i_R)
            begin
                o_Q <= 0;
                o_Q_b <= 1;
            end else if (i_S && !i_R)
            begin
                o_Q <= 1;
                o_Q_b <= 0;
            end else if (!i_S && i_R)
            begin
                o_Q <= 0;
                o_Q_b <= 1;
            end else // Both S and R low
            begin
                o_Q <= o_Q;
                o_Q_b <= o_Q_b;
            end
        end
    end

endmodule
