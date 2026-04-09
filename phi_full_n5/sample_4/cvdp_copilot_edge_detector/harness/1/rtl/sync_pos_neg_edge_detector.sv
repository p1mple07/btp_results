module sync_pos_neg_edge_detector (
    input clk,
    input rstb,
    input [1:0] detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    // State machine to detect edges
    typedef enum logic [1:0] {IDLE, POS_EDGE, NEG_EDGE} detection_state_t;
    detection_state_t state = IDLE;

    // Clock and reset synchronizer
    reg clock_sync_reg = 1'b0;
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            clock_sync_reg <= 1'b0;
            state <= IDLE;
            o_positive_edge_detected <= 1'b0;
            o_negative_edge_detected <= 1'b0;
        end else if (clock_sync_reg == 1'b0) begin
            clock_sync_reg <= clk;
        end
    end

    // State transition logic
    always @(posedge clk or negedge rstb) begin
        case (state)
            IDLE: begin
                if (detection_signal == 2'b00) begin
                    state <= POS_EDGE;
                    o_positive_edge_detected <= 1'b1;
                end
            end
            POS_EDGE: begin
                if (detection_signal == 2'b00) begin
                    state <= IDLE;
                    o_positive_edge_detected <= 1'b0;
                end
            end
            NEG_EDGE: begin
                if (detection_signal == 2'b10) begin
                    state <= IDLE;
                    o_negative_edge_detected <= 1'b1;
                end
            end
        endcase
    end

endmodule
