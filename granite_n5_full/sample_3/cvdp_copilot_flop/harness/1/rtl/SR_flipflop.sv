Module definition
module SR_flipflop(
    input i_S,        // Set input
    input i_R,        // Reset input
    input i_clk,      // Clock input
    input i_rst_b,    // Asynchronous active-low reset input
    output reg o_Q,   // Output Q
    output reg o_Q_b  // Inverted output Q
);

    // Local variable declaration
    reg s, r;           // Internal signals for S and R

    // Register declarations
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) // Asynchronous reset active-low
        begin
            s <= 1'b0;  // Set internal signal S to 0
            r <= 1'b1;  // Set internal signal R to 1
        end
        else
        begin
            s <= i_S;   // Update internal signal S based on i_S
            r <= i_R;   // Update internal signal R based on i_R

            // Calculate output Q
            if (s & ~r)
                o_Q <= 1'b1;  // Set output Q to 1 when S and ~R are true
            else
                o_Q <= 1'b0;  // Set output Q to 0 otherwise

            // Calculate inverted output Q
            o_Q_b <= ~o_Q;  // Invert the value of output Q
        end
    end

endmodule