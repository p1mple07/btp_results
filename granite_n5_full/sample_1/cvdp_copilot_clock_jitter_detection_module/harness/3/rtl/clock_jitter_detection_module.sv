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
            // Insert code to initialize counters, edge detection, and jitter detection on reset
            edge_count <= 0;
            edge_count_r <= 0;
            prev_system_clk <= 0;
            jitter_detected <= 0;
            start_counter <= 0;
        end else begin
            prev_system_clk <= system_clk;

            // Insert code to detect rising edge transitions of system_clk
            // Insert code to reset and increment edge_count as necessary

            // Insert code to compare edge_count_r with JITTER_THRESHOLD and detect jitter
            if ((prev_system_clk == 1) && (system_clk == 0)) begin
                edge_detected <= 1;
                start_counter <= 1;
                edge_count <= 0;
            end else if ((prev_system_clk == 0) && (system_clk == 1) && start_counter == 1) begin
                edge_count <= edge_count + 1;
            end else if ((prev_system_clk == 1) && (system_clk == 0) && start_counter == 1) begin
                start_counter <= 0;
            end else if ((prev_system_clk == 0) && (system_clk == 1) && start_counter == 0) begin
                if (edge_count > JITTER_THRESHOLD) begin
                    jitter_detected <= 1;
                end else begin
                    jitter_detected <= 0;
                end
                edge_count <= 0;
            end

        end
    end

endmodule