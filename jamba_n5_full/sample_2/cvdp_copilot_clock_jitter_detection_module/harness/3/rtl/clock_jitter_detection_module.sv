module clock_jitter_detection_module #(
    parameter JITTER_THRESHOLD = 5    // Threshold (in clock cycles) for detecting jitter
)(
    input logic clk,               // Input clock
    input logic system_clk,        // Input system clock
    input logic rst,               // Active high reset
    output logic jitter_detected   // Output flag indicating jitter detection
);

    // Internal signals
    logic [31:0] edge_count, edge_count_r;   // Counters to measure time between rising edges
    logic prev_system_clk;                   // To store the previous clock state (rising edge detection)
    logic edge_detected;                     // Flag for detecting rising edges
    logic start_counter;

    // Rising edge detection logic (detects when clock transitions from 0 to 1)
    always @(posedge clk) begin
        if (rst) begin
            // Reset all internal state
            edge_count <= 0;
            edge_count_r <= 0;
            prev_system_clk <= 1'b0;
            edge_detected <= 0;
        end else begin
            prev_system_clk <= system_clk;

            // Detect rising edge transitions of system_clk
            if (prev_system_clk == 1'b0 && system_clk == 1'b1) begin
                edge_detected = 1;
                edge_count <= 0;
                edge_count_r <= 0;
            end else begin
                edge_detected = 0;
            end
        end
    end

    // After the rising edge, we start counting the time until the next rising edge.
    // Here we simply set edge_count to 0 (for simplicity) and then after the next rising edge, we compare.

    // Compare edge_count_r with JITTER_THRESHOLD and set jitter_detected
    assign jitter_detected = edge_count_r >= JITTER_THRESHOLD_CYCLES;

endmodule
