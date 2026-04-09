module clock_jitter_detection_module #(
    parameter JITTER_THRESHOLD = 5    // Threshold (in clock cycles) for detecting jitter
)(
    input logic clk,               // Input clock
    input logic system_clk,        // Input system clock
    input logic rst,               // Active high reset
    output logic jitter_detected   // Output flag indicating jitter detection
);

    logic edge_detected;
    logic prev_system_clk;
    logic edge_detected;
    logic start_counter;

    always @(posedge clk) begin
        if (~rst) begin
            edge_detected = 1'b0;
            prev_system_clk <= 1'b0;
            edge_count <= 0;
            jitter_detected <= 1'b0;
        end else begin
            prev_system_clk <= system_clk;

            if (prev_system_clk == 1'b0 && system_clk == 1'b1) begin
                edge_detected = 1'b1;
                edge_count <= 0;
            end else begin
                edge_detected = 1'b0;
            end

            if (edge_detected) begin
                edge_count <= edge_count + 1;
                if (edge_count >= JITTER_THRESHOLD) begin
                    jitter_detected <= 1'b1;
                end else begin
                    jitter_detected <= 1'b0;
                end
            end
        end
    end

endmodule
