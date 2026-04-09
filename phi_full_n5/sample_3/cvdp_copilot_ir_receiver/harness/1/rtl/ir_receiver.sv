always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in)
        present_state <= idle;
    else
        present_state <= next_state;
end

always_comb begin
    case (present_state)
        idle: begin
            if (!started) begin
                if (ir_signal_in && !decoded) begin
                    started <= 1;
                    cycle_counter <= 0;
                    bit_counter <= 0;
                    ir_frame_reg <= 12'h0000;
                    decoded <= 0;
                    stored <= 0;
                    failed <= 0;
                    success <= 0;
                end else
                    failed <= 1;
            end else begin
                failed <= 0;
            end
        end
        
        start: begin
            if (started && ir_signal_in && (cycle_counter == 2400)) begin
                decoded <= 1;
                next_state <= decoding;
            end else
                failed <= 1;
        end
        
        decoding: begin
            if (ir_signal_in && (cycle_counter == 600 || cycle_counter == 1200 || cycle_counter == 1800 ||
                                 cycle_counter == 2400 || cycle_counter == 3000 || cycle_counter == 3600 ||
                                 cycle_counter == 4200 || cycle_counter == 4800 || cycle_counter == 5400 ||
                                 cycle_counter == 6000)) begin
                ir_frame_reg[bit_counter] <= ir_signal_in ? 12'h0001 : 12'h0000;
                bit_counter <= bit_counter + 1;
                if (bit_counter == 12) begin
                    next_state <= finish;
                end
            end else
                failed <= 1;
        end
        
        finish: begin
            if (bit_counter == 12) begin
                ir_frame_out <= ir_frame_reg;
                ir_frame_valid <= 1;
                next_state <= idle;
            end
        end
    endcase
end
