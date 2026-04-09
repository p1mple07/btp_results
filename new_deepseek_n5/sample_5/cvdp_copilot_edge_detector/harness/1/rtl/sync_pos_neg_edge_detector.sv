module sync_pos_neg_edge_detector(
    input clock,
    input rstb,
    input detection_signal,
    output positive_edge_detected,
    output negative_edge_detected
);

    // State variables
    reg rst_state = 0;
    reg prev_dect = 0;
    reg current_dect = 0;
    reg positive_edge_detected_local = 0;
    reg negative_edge_detected_local = 0;

    // Edge detection logic
    always @(posedge clock) begin
        if (rstb) begin
            rst_state = 0;
            positive_edge_detected_local = 0;
            negative_edge_detected_local = 0;
        else begin
            current_dect = detection_signal;
            if (prev_dect == 0 && current_dect == 1) begin
                positive_edge_detected_local = 1;
            end else if (prev_dect == 1 && current_dect == 0) begin
                negative_edge_detected_local = 1;
            end
            prev_dect = current_dect;
        end
    end

    // Gate the output with clock
    positive_edge_detected = positive_edge_detected_local & clock;
    negative_edge_detected = negative_edge_detected_local & clock;

endmodule