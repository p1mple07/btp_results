always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in)
        present_state <= idle;
    else
        present_state <= next_state;
end

always_comb begin
    case (present_state)
        idle: begin
            started <= 1'b0;
            decoded <= 1'b0;
            failed <= 1'b0;
            success <= 1'b0;
            bit_counter <= 0;
            cycle_counter <= 0;
            ir_frame_reg <= 12'b0;
            stored <= 1'b0;
        end
        start: begin
            if (ir_signal_in && !started) begin
                started <= 1'b1;
                started <= started;
            end else begin
                started <= 1'b0;
                started <= started;
            end
        end
        decoding: begin
            if (started) begin
                if (ir_signal_in) begin
                    ir_frame_reg[bit_counter] <= (ir_signal_in && cycle_counter == 0.6);
                    if (ir_frame_reg[bit_counter]) begin
                        bit_counter <= bit_counter + 1;
                        cycle_counter <= cycle_counter + 0.6;
                    end else begin
                        failed <= 1'b1;
                        failed <= failed;
                    end
                end else begin
                    failed <= 1'b1;
                    failed <= failed;
                end
            end else begin
                failed <= 1'b0;
                failed <= failed;
            end
        end
        finish: begin
            if (bit_counter == 12) begin
                decoded <= 1'b1;
                decoded <= decoded;
                if (cycle_counter >= 2.4) begin
                    ir_frame_out <= ir_frame_reg;
                    ir_frame_valid <= 1'b1;
                    ir_frame_valid <= ir_frame_valid;
                    started <= 1'b0;
                    decoded <= 1'b0;
                    bit_counter <= 0;
                    cycle_counter <= 0;
                    stored <= 1'b0;
                end
            end else begin
                failed <= 1'b0;
                failed <= failed;
            end
        end
endcase
endmodule
