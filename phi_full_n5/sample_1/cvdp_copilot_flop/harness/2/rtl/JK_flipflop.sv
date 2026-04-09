always @(posedge i_clk or negedge i_rst_b)
begin
    if (!i_rst_b) // If reset is active (low)
    begin
        o_Q <= 1'b0;   // Set Q to 0
        o_Q_b <= 1'b1; // Set Q_b to 1 (inverted Q)
    end
    else
    begin
        case ({i_J, i_K})
            2'b00: o_Q <= o_Q; // Hold state
            2'b01: o_Q <= 1'b0; // Reset state
            2'b10: o_Q <= 1'b1; // Set state
            2'b11: o_Q <= ~o_Q; // Toggle state
        endcase
        o_Q_b <= ~o_Q; // Inverted Q output
    end
end
