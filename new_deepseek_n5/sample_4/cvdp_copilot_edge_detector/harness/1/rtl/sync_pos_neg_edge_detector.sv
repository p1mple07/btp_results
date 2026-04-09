module sync_pos_neg_edge_detector(
    input clock,
    input rstb,
    input detection_signal,
    output positive_edge_detected,
    output negative_edge_detected
);

    // State machine states
    // 0: Reset state
    // 1: Idle state
    // 2: Positive edge detected
    // 3: Negative edge detected
    reg state = 0;

    // Edge detection variables
    reg positive_edge = 0;
    reg negative_edge = 0;

    // Sensitivity list for positive edge
    always_posedge detection_signal begin
        if (!rstb) begin
            positive_edge = 1;
            state = 2;
        end
        // Assert positive edge for one clock cycle
        $time #1 positive_edge_detected = 1;
        $time #1 positive_edge = 0;
    end

    // Sensitivity list for negative edge
    always_negedge detection_signal begin
        if (!rstb) begin
            negative_edge = 1;
            state = 3;
        end
        // Assert negative edge for one clock cycle
        $time #1 negative_edge_detected = 1;
        $time #1 negative_edge = 0;
    end

    // Reset functionality
    always begin
        if (rstb) begin
            positive_edge_detected = 1;
            negative_edge_detected = 1;
            state = 0;
        end
    end

    // Cleanup after detection
    always begin
        if (rstb) begin
            positive_edge = 0;
            negative_edge = 0;
        end
    end

endmodule