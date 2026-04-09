module enhanced_fsm_signal_processor(
    input                 i_clk,
    input                 i_rst_n,
    input [4:0]          i_enable,
    input                 i_clear,
    input [4:0]          i_ack,
    input                 i_fault,
    input [4:0]          i_vector_1,
    input                 i_vector_2,
    input                 i_vector_3,
    input                 i_vector_4,
    input                 i_vector_5,
    input                 i_vector_6,
    output reg           o_ready,
    output reg           o_error,
    output reg [1:0]     o_fsm_status,
    output reg [7:0]     o_vector_1,
    output reg [7:0]     o_vector_2,
    output reg [7:0]     o_vector_3,
    output reg [7:0]     o_vector_4
);

// Reset the entire system
always @(i_rst_n) begin
    if (i_rst_n) begin
        o_ready         <= 1'b0;
        o_error         <= 1'b0;
        o_fsm_status    <= "d0";
        o_vector_1      <= {31:0} 0;
        o_vector_2      <= {31:0} 0;
        o_vector_3      <= {31:0} 0;
        o_vector_4      <= {31:0} 0;
        return;
    end
end

// Re‑enable on positive edge of clock
always @(posedge i_clk) begin
    if (~i_rst_n) begin
        // Normal operation begins
        o_ready         <= 1'b0;
        o_error         <= 1'b0;
        o_fsm_status    <= "d0";
    end else begin
        // Continue processing state
        o_ready         <= 1'b0;
    end
end

// Handle enable, fault and acknowledge signals
always @(posedge i_clk) begin
    if (i_enable) begin
        if (i_fault) begin
            o_error         <= 1'b1;
            o_fsm_status    <= "fa";
            return;
        end

        if (i_ack) begin
            o_ready         <= 1'b1;
        end

        // Proceed to process state
        o_fsm_status       <= "01";
    end
end

// Enter ready state after ACK is received
always @(posedge i_clk) begin
    if (o_ready) begin
        o_ready         <= 1'b0;
    end
end

// Return to idle on clear or reset
always @(posedge i_clk) begin
    if (i_clear) begin
        o_ready         <= 1'b0;
        o_error         <= 1'b0;
        o_fsm_status    <= "d0";
    end else if (i_rst_n) begin
        o_ready         <= 1'b0;
        o_error         <= 1'b0;
        o_fsm_status    <= "d0";
    end
end

// Finalise output vectors
always @(posedge i_clk) begin
    if (o_ready) begin
        o_vector_1      <= {31:0} 0;
        o_vector_2      <= {31:0} 0;
        o_vector_3      <= {31:0} 0;
        o_vector_4      <= {31:0} 0;
    end
end

endmodule
