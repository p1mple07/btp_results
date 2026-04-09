module JK_flipflop(
    input i_J,       // J input of the JK flip-flop
    input i_K,       // K input of the JK flip-flop
    input i_clk,     // Clock input
    input i_rst_b,   // Asynchronous reset, active low
    output reg o_Q,  // Q output
    output reg o_Q_b // Inverted Q output
);

    // Always block triggered on the rising edge of the clock or the falling edge of the reset
    always @(posedge i_clk or negedge i_rst_b) begin
        if (!i_rst_b) begin
            o_Q   <= 1'b0;
            o_Q_b <= 1'b1;
        end else begin
            // Declare a temporary variable to compute the new state
            bit new_Q;
            case ({i_J, i_K})
                2'b00: new_Q = o_Q;     // Hold state
                2'b01: new_Q = 1'b0;    // Reset state
                2'b10: new_Q = 1'b1;    // Set state
                2'b11: new_Q = ~o_Q;    // Toggle state
            endcase
            o_Q   <= new_Q;
            o_Q_b <= ~new_Q;
        end
    end

endmodule