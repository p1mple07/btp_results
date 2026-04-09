module fsm_seq_detector (
    input clk_in,
    input rst_in,
    input seq_in,
    output reg seq_detected
);

reg [2:0] state;

always_ff @(posedge clk_in or posedge rst_in) begin
    if (!rst_in) begin
        state <= 0;
        seq_detected <= 0;
    end else begin
        case (state)
            0: // S0
                if (seq_in == 1'b1) state <= 1;
                end
            1: // S1
                if (seq_in == 1'b0) state <= 2;
                else if (seq_in == 1'b1) state <= 3;
                end
            2: // S2
                if (seq_in == 1'b1) state <= 4;
                end
            3: // S3
                if (seq_in == 1'b1) state <= 5;
                end
            4: // S4
                if (seq_in == 1'b0) state <= 6;
                end
            5: // S5
                if (seq_in == 1'b0) state <= 7;
                end
            6: // S6
                if (seq_in == 1'b1) state <= 0;
                end
            7: // S7
                if (seq_in == 1'b1) state <= 1;
                end
        endcase
    end
end

always_comb begin
    seq_detected = (state == 7) && seq_in == 1'b1;
end

endmodule
