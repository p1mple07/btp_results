module fsm_seq_detector (
    input clk_in,
    input rst_in,
    input seq_in,
    output seq_detected
);

    // State definitions
    logic [2:0] state;
    reg seq_detected;
    reg detection_done;

    // Sequence bits
    localparam const seq_bits[7:0] = {
        1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1
    };

    // Always blocks
    always_comb begin
        seq_detected = 0;
        detection_done = 0;
        if (state == 7) begin
            detection_done = 1;
        end
    end

    always_ff @(posedge clk_in or negedge rst_in) begin
        if (!rst_in) begin
            state <= 0;
            detection_done <= 0;
            seq_detected <= 0;
        end else begin
            case(state)
                S0: begin
                    if (seq_in == 1'b1) state <= 1;
                    else state <= 0;
                end
                S1: begin
                    if (seq_in == 1'b0) state <= 2;
                    else state <= 0;
                end
                S2: begin
                    if (seq_in == 1'b1) state <= 3;
                    else state <= 0;
                end
                S3: begin
                    if (seq_in == 1'b1) state <= 4;
                    else state <= 0;
                end
                S4: begin
                    if (seq_in == 1'b0) state <= 5;
                    else state <= 0;
                end
                S5: begin
                    if (seq_in == 1'b0) state <= 6;
                    else state <= 0;
                end
                S6: begin
                    if (seq_in == 1'b0) state <= 7;
                    else state <= 0;
                end
                S7: begin
                    if (seq_in == 1'b1) detection_done <= 1;
                    else detection_done <= 0;
                end
            end
        end
    end

endalways

always @(*) begin
    seq_detected <= detection_done;
end

always begin
    if (seq_detected) begin
        seq_detected <= 0;
    end
end

endmodule
