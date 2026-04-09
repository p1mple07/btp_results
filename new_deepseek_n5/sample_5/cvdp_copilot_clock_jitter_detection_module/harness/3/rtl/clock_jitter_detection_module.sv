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
    logic jitter_asserted;                   // To assert jitter_detected for one cycle

    // Rising edge detection logic (detects when clock transitions from 0 to 1)
    always @(posedge clk) begin
        if (rst) begin
            // Initialize counters, edge detection, and jitter detection on reset
            edge_count <= 0;
            edge_count_r <= 0;
            edge_detected <= 0;
            start_counter <= 0;
            jitter_asserted <= 0;
        end else begin
            prev_system_clk <= system_clk;

            // Detect rising edge transitions of system_clk
            if (!edge_detected && system_clk) begin
                edge_detected <= 1;
                edge_count <= 0;
                start_counter <= 1;
            end

            // Count clock cycles between rising edges
            if (edge_detected) begin
                edge_count <= edge_count + 1;
                if (edge_count_r != edge_count) begin
                    jitter_asserted <= 1;
                end
                edge_detected <= 0;
            end

            // Reset jitter_asserted after one cycle
            if (jitter_asserted && !rst) begin
                jitter_asserted <= 0;
            end
        end
    end

endmodule