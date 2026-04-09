module SR_flipflop(
    input  i_S,        // Set input
    input  i_R,        // Reset input
    input  i_clk,      // Clock input
    input  i_rst_b,    // Asynchronous active-low reset input
    output reg o_Q,    // Output Q
    output reg o_Q_b   // Inverted output Q
);

    // Always block triggered on the positive edge of the clock or negative edge of the asynchronous reset
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) // Asynchronous reset active (active low)
        begin
            o_Q   <= 1'b0;      // Force output Q to low
            o_Q_b <= 1'b1;      // Force inverted output Q to high
        end
        else
        begin
            // Use a case statement for clarity:
            // 2'b10: Set condition (i_S=1, i_R=0)
            // 2'b01: Reset condition (i_S=0, i_R=1)
            // 2'b00: Hold state (both inputs low)
            // 2'b11: Invalid state (both inputs high) - default to reset state
            case({i_S, i_R})
                2'b10: begin
                    o_Q   <= 1'b1;   // Set Q to high
                    o_Q_b <= 1'b0;   // Invert Q to low
                end
                2'b01: begin
                    o_Q   <= 1'b0;   // Reset Q to low
                    o_Q_b <= 1'b1;   // Invert Q to high
                end
                2'b00: begin
                    // No change: hold the previous state
                end
                2'b11: begin
                    // Invalid state: default to reset state
                    o_Q   <= 1'b0;
                    o_Q_b <= 1'b1;
                end
            endcase
        end
    end

endmodule