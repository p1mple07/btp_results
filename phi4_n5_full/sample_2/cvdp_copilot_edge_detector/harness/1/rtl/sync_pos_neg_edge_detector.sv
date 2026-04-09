module sync_pos_neg_edge_detector (
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
            prev_signal            <= 1'b0;
            o_positive_edge_detected <= 1'b0;
            o_negative_edge_detected <= 1'b0;
        end else begin
            // Capture the current state for next cycle's comparison
            prev_signal <= i_detection_signal;
            
            // Detect a positive edge: transition from 0 to 1
            o_positive_edge_detected <= (prev_signal == 1'b0) && (i_detection_signal == 1'b1);
            
            // Detect a negative edge: transition from 1 to 0
            o_negative_edge_detected <= (prev_signal == 1'b1) && (i_detection_signal == 1'b0);
        end
    end

endmodule