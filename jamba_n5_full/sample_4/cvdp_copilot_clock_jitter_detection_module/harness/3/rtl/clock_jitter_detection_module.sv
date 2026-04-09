module clock_jitter_detection_module #(
    parameter JITTER_THRESHOLD = 5    // Threshold (in clock cycles) for detecting jitter
)(
    input logic clk,
    input logic system_clk,
    input logic rst,
    output logic jitter_detected
);

    // Internal signals
    logic [31:0] edge_count, edge_count_r;   // Counters to measure time between rising edges
    logic prev_system_clk;                   // To store the previous clock state (rising edge detection)
    logic edge_detected;                     // Flag for detecting rising edges
    logic start_counter;

    // Rising edge detection logic (detects when clock transitions from 0 to 1)
    always @(posedge clk) begin
        if (rst) begin
            // Reset logic: clear counters, etc.
            edge_count <= 0;
            edge_count_r <= 0;
            prev_system_clk <= 1'b0;
            jitter_detected <= 0;
        end else begin
            prev_system_clk <= system_clk;

            // Detect rising edge: when previous was 0 and current is 1
            if (prev_system_clk == 1'b0 && system_clk == 1'b1) begin
                edge_detected <= 1;
            end else
                edge_detected <= 0;

            // Count cycles: increment edge_count when edge_detected is true
            if (edge_detected) begin
                edge_count <= edge_count + 1;
            end

            // Compare with threshold
            if (edge_count_r > JITTER_THRESHOLD) begin
                jitter_detected <= 1;
            end else
                jitter_detected <= 0;

            // Reset counters on new rising edge
            if (edge_detected && prev_system_clk == 1'b0 && system_clk == 1'b1) begin
                edge_count <= 0;
                edge_count_r <= 0;
            end

            // Start counter for new period
            start_counter <= 1;
        end
    end

endmodule
