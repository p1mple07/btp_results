module SR_flipflop(
    input i_S,        // Set input
    input i_R,        // Reset input
    input i_clk,      // Clock input
    input i_rst_b,    // Asynchronous active-low reset input
    output reg o_Q,   // Output Q
    output reg o_Q_b  // Inverted output Q
);

    // Always block triggered on the positive edge of the clock
    always @(posedge i_clk or negedge i_rst_b)
    begin
        if (!i_rst_b) // Asynchronous reset active-low
        begin
            o_Q   <= 1'b0;  // Force output Q to low
            o_Q_b <= 1'b1;  // Force inverted output Q to high
        end
        else
        begin
            // Synchronous operation based on i_S and i_R
            if (i_S && i_R) begin
                // Invalid state: both set and reset are high.
                // For safety, force outputs to a defined state.
                o_Q   <= 1'b0;
                o_Q_b <= 1'b1;
            end
            else if (i_S) begin
                // Set operation: set output Q to high.
                o_Q   <= 1'b1;
                o_Q_b <= 1'b0;
            end
            else if (i_R) begin
                // Reset operation: reset output Q to low.
                o_Q   <= 1'b0;
                o_Q_b <= 1'b1;
            end
            else begin
                // Hold state: retain previous value when both inputs are low.
            end
        end
    end

endmodule