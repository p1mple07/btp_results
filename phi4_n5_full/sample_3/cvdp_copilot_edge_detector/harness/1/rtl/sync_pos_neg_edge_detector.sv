module sync_pos_neg_edge_detector(
    input  logic i_clk,
    input  logic i_rstb,
    input  logic i_detection_signal,
    output logic o_positive_edge_detected,
    output logic o_negative_edge_detected
);

    // Register to store the previous value of the detection signal
    logic prev_detection_signal;

    // Edge detection and pulse generation
    always_ff @(posedge i_clk or negedge i_rstb) begin
        if (!i_rstb) begin
            // Asynchronous reset: clear outputs and previous signal
            prev_detection_signal  <= 1'b0;
            o_positive_edge_detected <= 1'b0;
            o_negative_edge_detected <= 1'b0;
        end else begin
            // Detect a positive (rising) edge
            if (i_detection_signal && !prev_detection_signal)
                o_positive_edge_detected <= 1'b1;
            else
                o_positive_edge_detected <= 1'b0;

            // Detect a negative (falling) edge
            if (!i_detection_signal && prev_detection_signal)
                o_negative_edge_detected <= 1'b1;
            else
                o_negative_edge_detected <= 1'b0;

            // Update the previous value for next comparison
            prev_detection_signal <= i_detection_signal;
        end
    end

endmodule