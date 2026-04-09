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
            // Initialize counters, edge detection, and jitter detection on reset
            edge_count <= 0;
            prev_system_clk <= 1;
            edge_detected <= 0;
            start_counter <= 1;
            jitter_detected <= 0;
        end else begin
            // Detect rising edge transitions of system_clk
            if (!prev_system_clk && system_clk) begin
                edge_count <= 0;
                start_counter <= 1;
                edge_detected <= 1;
            end else if (start_counter) begin
                edge_count <= edge_count + 1;
                start_counter <= 0;
            end

            // Compare edge_count_r with JITTER_THRESHOLD and detect jitter
            if (edge_detected && (edge_count > JITTER_THRESHOLD)) begin
                jitter_detected <= 1;
            end

            // Store previous system clock state for next iteration
            prev_system_clk <= system_clk;
        end
    end

endmodule