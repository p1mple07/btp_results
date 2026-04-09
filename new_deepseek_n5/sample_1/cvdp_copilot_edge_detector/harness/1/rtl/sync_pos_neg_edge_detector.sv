module sync_pos_neg_edge_detector(
    input clock,
    input rstb,
    input detection_signal,
    output positive_edge_detected,
    output negative_edge_detected
);

    // State variable to manage edge detection state
    reg state = RESET;

    // Edge detection events
    reg edge_pos, edge_neg;

    // State transitions
    always_comb begin
        if (rstb) begin
            state = RESET;
            positive_edge_detected = 0;
            negative_edge_detected = 0;
        else begin
            state = NORMAL;
        end
    end

    // Edge detection logic
    always_ff @posedge detection_signal begin
        if (state == NORMAL) begin
            edge_pos = 1;
            positive_edge_detected = 1;
            positive_edge_detected after 1 clock cycle = 0;
        end
    end

    always_ff @negedge detection_signal begin
        if (state == NORMAL) begin
            edge_neg = 1;
            negative_edge_detected = 1;
            negative_edge_detected after 1 clock cycle = 0;
        end
    end

    // Reset all outputs when in NORMAL state
    always_ff @posedge clock begin
        if (rstb) begin
            positive_edge_detected = 0;
            negative_edge_detected = 0;
        end
    end

    // Ensure proper state handling
    always_ff @posedge clock begin
        if (rstb) begin
            state = RESET;
        end
    end

    // Cleanup after edge detection
    always_ff @negedge clock begin
        if (rstb) begin
            positive_edge_detected = 0;
            negative_edge_detected = 0;
        end
    end

endmodule