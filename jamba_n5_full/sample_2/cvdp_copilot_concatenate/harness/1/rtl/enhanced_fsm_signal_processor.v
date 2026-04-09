module enhanced_fsm_signal_processor (
    input i_clk,
    input i_rst_n,
    input i_enable,
    input i_clear,
    input i_ack,
    input i_fault,
    input [4:0] vector_1, vector_2, vector_3, vector_4, vector_5, vector_6,
    output o_ready,
    output o_error,
    output [7:0] o_vector_1, o_vector_2, o_vector_3, o_vector_4,
    output o_fsm_status,
    output o_vector_5, o_vector_6?  // We can omit
);

// Reset on inactive
always @(posedge i_clk or i_rst_n) begin
    if (i_rst_n) begin
        o_ready <= 0;
        o_error <= 0;
        o_vector_1 <= 0;
        o_vector_2 <= 0;
        o_vector_3 <= 0;
        o_vector_4 <= 0;
        o_fsm_status <= 1;
    end else if (i_enable) begin
        if (!i_clear && !i_fault) begin
            // Process
            // For simplicity, assume we just copy vectors
            o_vector_1 <= vector_1;
            o_vector_2 <= vector_2;
            o_vector_3 <= vector_3;
            o_vector_4 <= vector_4;
            o_ready <= 1;
            o_error <= 0;
        end else if (i_clear) begin
            // Clear outputs and reset fault
            o_ready <= 1;
            o_error <= 0;
            o_vector_1 <= 0;
            o_vector_2 <= 0;
            o_vector_3 <= 0;
            o_vector_4 <= 0;
            o_fsm_status <= 1;
        end else if (i_fault) begin
            // Fault
            o_ready <= 0;
            o_error <= 1;
            o_vector_1 <= 0;
            o_vector_2 <= 0;
            o_vector_3 <= 0;
            o_vector_4 <= 0;
            o_fsm_status <= 11;
        end
    end else if (i_ack) begin
        // Acknowledge: return to idle
        o_ready <= 1;
        o_error <= 0;
        o_vector_1 <= 0;
        o_vector_2 <= 0;
        o_vector_3 <= 0;
        o_vector_4 <= 0;
        o_fsm_status <= 1;
    end
end

// Fallback for uninitialized state
always @(*) begin
    if (~i_rst_n) begin
        o_ready <= 0;
        o_error <= 0;
        o_vector_1 <= 0;
        o_vector_2 <= 0;
        o_vector_3 <= 0;
        o_vector_4 <= 0;
        o_fsm_status <= 1;
    end
end

endmodule
