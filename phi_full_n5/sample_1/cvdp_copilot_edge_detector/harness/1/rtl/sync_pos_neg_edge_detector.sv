module sync_pos_neg_edge_detector(
    input clk,
    input rstb,
    input glitch_free_debounced_signal,
    output reg pos_edge_detected,
    output reg neg_edge_detected
);

    reg [1:0] state;
    reg [1:0] next_state;

    // State encoding
    always @(posedge clk or posedge rstb) begin
        if (rstb) begin
            state <= 2'b00;
            pos_edge_detected <= 0;
            neg_edge_detected <= 0;
        end else begin
            state <= next_state;
        end
    end

    // State transition logic
    always @(posedge clk) begin
        next_state = state;
        case (state)
            2'b00: begin // Idle state
                if (glitch_free_debounced_signal) begin
                    pos_edge_detected <= 1;
                    next_state <= 2'b01;
                end else begin
                    next_state <= 2'b00;
                end
            end
            2'b01: begin // Positive edge detected
                neg_edge_detected <= 0;
                pos_edge_detected <= 0;
                next_state <= 2'b00;
            end
            2'b10: begin // Negative edge detected
                pos_edge_detected <= 0;
                neg_edge_detected <= 1;
                next_state <= 2'b00;
            end
        endcase
    end

endmodule
