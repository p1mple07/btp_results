module SR_flipflop(
    input i_S,        // Set signal
    input i_R,        // Reset signal
    input i_clk,      // Clock signal
    input i_rst_b,    // Asynchronous active-low reset signal
    output reg o_Q,   // Output Q
    output reg o_Q_b  // Inverted output Q
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
            case ({i_S, i_R})
                1'b0, 1'b0: // Hold state
                    // No change
                1'b0, 1'b1: // Invalid state (should not occur)
                    o_Q <= 1'b0;
                    o_Q_b <= 1'b1;
                1'b1, 1'b0: // Set
                    o_Q <= 1'b1;
                    o_Q_b <= 1'b0;
                default: // Reset
                    o_Q <= 1'b0;
                    o_Q_b <= 1'b1;
            endcase
        end
    end

endmodule