module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16, 
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
)(
    clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);

    localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH;

    // Guard against the impossible case of zero sequence length
    if (SEQUENCE_LENGTH == 0) begin
        out_val <= 0;
        done <= 0;
    end else begin
        // Original implementation for non‑zero SEQUENCE_LENGTH
        localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH;

        always_ff @(posedge clk or negedge resetn) begin
            if (!resetn) begin
                current_val <= 0;
                counter <= 0;
                done <= 1'b0;
            end else if (enable) begin
                if (!done) begin
                    if (counter == 0) begin
                        current_val <= start_val;
                    end else begin
                        current_val <= current_val + step_size;
                    end
                    if (counter < SEQUENCE_LENGTH - 1) begin
                        counter <= counter + 1;
                    end else begin
                        done <= 1'b1;
                    end
                end
            end
        end
    end

    assign out_val = current_val;
endmodule
