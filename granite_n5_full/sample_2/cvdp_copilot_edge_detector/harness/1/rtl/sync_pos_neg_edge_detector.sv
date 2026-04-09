module sync_pos_neg_edge_detector(
    input wire i_clk,
    input wire i_rstb,
    input wire i_detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

reg [1:0] state;

always @(posedge i_clk or posedge i_rstb) begin
    if (i_rstb == 1'b0) begin
        // Reset state and outputs
        state <= 2'b00;
        o_positive_edge_detected <= 1'b0;
        o_negative_edge_detected <= 1'b0;
    end else begin
        case (state)
            2'b00: begin
                // Initial state, wait for positive edge detection
                if (i_detection_signal == 1'b1) begin
                    state <= 2'b01;
                end
            end
            2'b01: begin
                // Positive edge detected, output and reset state
                o_positive_edge_detected <= 1'b1;
                state <= 2'b10;
            end
            2'b10: begin
                // Negative edge detected, output and reset state
                o_negative_edge_detected <= 1'b1;
                state <= 2'b00;
            end
            default: begin
                // Invalid state, stay in current state
                state <= 2'b00;
            end
        endcase
    end
end

endmodule