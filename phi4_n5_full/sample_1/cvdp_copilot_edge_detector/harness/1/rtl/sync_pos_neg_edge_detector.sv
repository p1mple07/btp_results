module sync_pos_neg_edge_detector(
    input  logic i_clk,
    input  logic i_rstb,
    input  logic i_detection_signal,
    output logic o_positive_edge_detected,
    output logic o_negative_edge_detected
);

    // Register to hold the previous state of the detection signal
    logic prev_signal;

    always_ff @(posedge i_clk or negedge i_rstb) begin
        if (!i_rstb) begin
            prev_signal               <= 1'b0;
            o_positive_edge_detected  <= 1'b0;
            o_negative_edge_detected  <= 1'b0;
        end else begin
            // Detect positive edge: rising transition
            if (i_detection_signal && !prev_signal)
                o_positive_edge_detected <= 1'b1;
            else
                o_positive_edge_detected <= 1'b0;

            // Detect negative edge: falling transition
            if (!i_detection_signal && prev_signal)
                o_negative_edge_detected <= 1'b1;
            else
                o_negative_edge_detected <= 1'b0;

            // Update the previous signal state for next cycle
            prev_signal <= i_detection_signal;
        end
    end

endmodule