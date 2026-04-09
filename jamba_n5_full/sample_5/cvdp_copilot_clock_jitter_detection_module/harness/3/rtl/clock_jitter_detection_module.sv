module clock_jitter_detection_module #(
    parameter JITTER_THRESHOLD = 5    // Threshold (in clock cycles) for detecting jitter
)(
    input logic clk,
    input logic system_clk,
    input logic rst,
    output logic jitter_detected
);

    reg [31:0] edge_count, edge_count_r;
    reg prev_system_clk;
    reg edge_detected;
    reg start_counter;

    always @(posedge clk) begin
        if (!prev_system_clk) begin
            edge_detected = 1;
            edge_count <= 0;
            prev_system_clk = system_clk;
        end else if (system_clk && !prev_system_clk) begin
            edge_count <= edge_count + 1;
            prev_system_clk = system_clk;
        end
    end

    always @(*) begin
        jitter_detected = edge_count_r > JITTER_THRESHOLD;
    end

endmodule
