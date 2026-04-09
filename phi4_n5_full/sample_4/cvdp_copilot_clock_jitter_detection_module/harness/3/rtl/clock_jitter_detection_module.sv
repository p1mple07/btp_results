module.sv
module clock_jitter_detection_module #(
    parameter JITTER_THRESHOLD = 5    // Threshold (in clock cycles) for detecting jitter
)(
    input  logic         clk,       // Primary clock
    input  logic         system_clk,// System clock to be monitored for jitter
    input  logic         rst,       // Active-high reset
    output logic         jitter_detected // Flag indicating jitter detection
);

    // Internal signals
    logic [31:0] edge_count;      // Current counter value (number of clk cycles since last rising edge)
    logic [31:0] edge_count_r;    // Previous measurement (for comparison)
    logic         prev_system_clk; // Registered previous state of system_clk for rising edge detection

    // Rising edge detection and counter logic
    always @(posedge clk) begin
        if (rst) begin
            prev_system_clk    <= 1'b0;
            edge_count         <= 32'd0;
            edge_count_r       <= 32'd0;
            jitter_detected    <= 1'b0;
        end
        else begin
            // Check for rising edge of system_clk using registered previous state
            if (system_clk && !prev_system_clk) begin
                // Rising edge detected: capture current counter value for comparison
                edge_count_r <= edge_count;
                // Only perform jitter check if we have a valid measurement (ignore initial 0 count)
                if (edge_count != 32'd0) begin
                    // If the measured cycles deviate from JITTER_THRESHOLD by more than 1 cycle, flag jitter
                    if ((edge_count > (JITTER_THRESHOLD + 1)) || (edge_count < (JITTER_THRESHOLD - 1)))
                        jitter_detected <= 1'b1;
                    else
                        jitter_detected <= 1'b0;
                end
                // Reset counter for next measurement cycle
                edge_count <= 32'd0;
            end
            else begin
                // No rising edge: increment the counter
                edge_count <= edge_count + 32'd1;
                jitter_detected <= 1'b0;
            end

            // Update the registered previous state of system_clk
            prev_system_clk <= system_clk;
        end
    end

endmodule