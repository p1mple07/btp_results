module sync_pos_neg_edge_detector(
    input clock,
    input rstb,
    input detection_signal,
    output positive_edge_detected,
    output negative_edge_detected
);
    // State variables to track edge detection
    reg positive_edge;
    reg negative_edge;
    
    // Positive edge detection (rising transition)
    positive_edge = (detection_signal & ~prev(detection_signal)) & ~rstb;
    
    // Negative edge detection (falling transition)
    negative_edge = (~detection_signal & prev(detection_signal)) & ~rstb;
    
    // Output the detected edges
    positive_edge_detected = positive_edge;
    negative_edge_detected = negative_edge;
endmodule