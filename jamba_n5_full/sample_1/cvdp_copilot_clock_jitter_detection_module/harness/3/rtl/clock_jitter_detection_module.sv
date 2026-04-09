module clock_jitter_detection_module #(
    parameter JITTER_THRESHOLD = 5
) (
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
        if (rst) begin
            edge_count <= 0;
            edge_count_r <= 0;
            prev_system_clk <= 0;
            edge_detected <= 0;
            start_counter <= 1;
        end else begin
            prev_system_clk <= system_clk;
            if (system_clk == 1'b1 && prev_system_clk == 0) begin
                edge_detected = 1;
                edge_count <= 0;
                edge_count_r <= 0;
            end

            if (edge_detected && start_counter == 0) begin
                start_counter = 1;
                edge_count <= 0;
            end else begin
                if (edge_detected) begin
                    edge_count <= edge_count + 1;
                end else begin
                    edge_count <= 0;
                end
            end
        end
    end

    assign jitter_detected = start_counter && edge_count_r >= JITTER_THRESHOLD;

endmodule
