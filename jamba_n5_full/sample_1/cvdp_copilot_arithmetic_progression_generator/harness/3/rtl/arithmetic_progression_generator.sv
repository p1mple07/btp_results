module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10,
    parameter WIDTH_OUT_VAL = ($clog2(start_val + (SEQ_LENGTH - 1) * step_size) + 1)
)(
    clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);

always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        current_val <= 0;
        counter <= 0;
        done <= 1'b0;
    end else if (enable) begin
        if (!done) begin
            if (counter < WIDTH_OUT_VAL) begin
                current_val = current_val + step_size;
                out_val = current_val;
            end
            counter = counter + 1;
        end else begin
            done <= 1'b1;
        end
    end else begin
        done <= 1'b0;
    end
end

assign out_val = current_val;

endmodule
