module sync_pos_neg_edge_detector(
    input wire i_clk,
    input wire i_rstb,
    input wire i_detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    // State machine for edge detection
    typedef enum logic [1:0] {IDLE, POS_EDGE, NEG_EDGE} state_t;
    state_t current_state, next_state;

    // Initial state
    initial begin
        current_state = IDLE;
    end

    // State transition logic
    always_comb begin
        case (current_state)
            IDLE: begin
                if (i_detection_signal) begin
                    next_state = POS_EDGE;
                end else begin
                    next_state = IDLE;
                end
            end
            POS_EDGE: begin
                if (!i_detection_signal) begin
                    next_state = NEG_EDGE;
                end else begin
                    o_positive_edge_detected = 1;
                    next_state = NEG_EDGE;
                end
            end
            NEG_EDGE: begin
                if (i_detection_signal) begin
                    next_state = POS_EDGE;
                end else begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // Reset logic
    always_ff @(posedge i_clk or posedge i_rstb) begin
        if (i_rstb) begin
            current_state <= IDLE;
            o_positive_edge_detected <= 0;
            o_negative_edge_detected <= 0;
        end else begin
            current_state <= next_state;
        end
    end

endmodule
