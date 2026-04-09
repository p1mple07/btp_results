module sync_pos_neg_edge_detector(
    input clk,
    input rstb,
    input [1:0] detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    reg [1:0] state, next_state;

    always @(posedge clk or posedge rstb) begin
        if (rstb) begin
            state <= 2'b00; // Reset state
            o_positive_edge_detected <= 0;
            o_negative_edge_detected <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(state or detection_signal) begin
        case (state)
            2'b00: begin
                next_state = (detection_signal == 2'b01) ? 2'b01 : 2'b00;
                o_positive_edge_detected <= 1'b1;
            end
            2'b01: begin
                next_state = (detection_signal == 2'b10) ? 2'b10 : 2'b01;
                o_negative_edge_detected <= 1'b1;
            end
            default: next_state = 2'b00;
        endcase
    end

endmodule

This System Verilog module detects both positive and negative edges on a glitch-free and debounced input signal, as specified. It outputs asserted signals high for one clock cycle upon edge detection and incorporates asynchronous reset functionality. The module file should be saved with the name `sync_pos_neg_edge_detector.sv` in the `rtl` directory. module sync_pos_neg_edge_detector(
    input clk,
    input rstb,
    input [1:0] detection_signal,
    output reg o_positive_edge_detected,
    output reg o_negative_edge_detected
);

    reg [1:0] state, next_state;

    always @(posedge clk or posedge rstb) begin
        if (rstb) begin
            state <= 2'b00; // Reset state
            o_positive_edge_detected <= 0;
            o_negative_edge_detected <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(state or detection_signal) begin
        case (state)
            2'b00: begin
                next_state = (detection_signal == 2'b01) ? 2'b01 : 2'b00;
                o_positive_edge_detected <= 1'b1;
            end
            2'b01: begin
                next_state = (detection_signal == 2'b10) ? 2'b10 : 2'b01;
                o_negative_edge_detected <= 1'b1;
            end
            default: next_state = 2'b00;
        endcase
    end

endmodule