module sync_pos_neg_edge_detector(
    input clock,
    input rstb,
    input detection_signal,
    output positive_edge_detected,
    output negative_edge_detected
);
    // State variable: 0 = Reset, 1 = Idle, 2 = Positive Edge, 3 = Negative Edge
    reg state = 0;
    reg positive_edge_detected, negative_edge_detected;
    reg next_state = 0;

    // State transitions
    alwaysposedge clock begin
        case (state)
            0:
                if (detection_signal) begin
                    positive_edge_detected = 1;
                    next_state = 2;
                end else begin
                    negative_edge_detected = 0;
                    next_state = 0;
                end
                // After edge is detected, wait one clock cycle
                #1 positive_edge_detected = 0;
                #1 negative_edge_detected = 0;
                next_state = 0;
                // Reset ifrstb is low
                if (rstb) begin
                    positive_edge_detected = 0;
                    negative_edge_detected = 0;
                    next_state = 0;
                end
                // If no edge detected, wait one clock cycle
                #1 positive_edge_detected = 0;
                #1 negative_edge_detected = 0;
                next_state = 0;
            end
            1:
                if (detection_signal) begin
                    negative_edge_detected = 1;
                    next_state = 3;
                end else begin
                    positive_edge_detected = 0;
                    next_state = 1;
                end
                // After edge is detected, wait one clock cycle
                #1 negative_edge_detected = 0;
                #1 positive_edge_detected = 0;
                next_state = 1;
            end
            2:
                if (rstb) begin
                    positive_edge_detected = 0;
                    negative_edge_detected = 0;
                    next_state = 0;
                end
                #1 positive_edge_detected = 0;
                #1 negative_edge_detected = 0;
                next_state = 0;
            end
            3:
                if (rstb) begin
                    positive_edge_detected = 0;
                    negative_edge_detected = 0;
                    next_state = 0;
                end
                #1 negative_edge_detected = 0;
                #1 positive_edge_detected = 0;
                next_state = 0;
            end
        default:
            // No transition
            next_state = state;
        endcase
    end
endmodule