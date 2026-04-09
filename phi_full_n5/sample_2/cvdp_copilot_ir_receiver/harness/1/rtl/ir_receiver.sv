always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in)
        present_state <= idle;
    else
        case (present_state)
            idle: begin
                if (ir_signal_in && !started) begin
                    started <= !ir_signal_in; // Detect start bit
                    cycle_counter <= 0;
                    bit_counter <= 0;
                end
                next_state <= idle;
            end
            start: begin
                if (started && (cycle_counter >= 2400)) begin // 2.4ms at 100KHz
                    started <= 0;
                    next_state <= decoding;
                end
                else begin
                    failed <= 1; // Invalid timing for start bit
                    next_state <= idle;
                end
            end
            decoding: begin
                if (ir_signal_in && bit_counter < 12) begin
                    if (ir_signal_in == '0) begin
                        ir_frame_reg[bit_counter] <= 0b00;
                    end else begin
                        ir_frame_reg[bit_counter] <= 0b01;
                    end
                    bit_counter <= bit_counter + 1;
                    if (bit_counter == 12) begin
                        success <= 1; // All bits decoded successfully
                        next_state <= finish;
                    end
                end
                else begin
                    failed <= 1; // Invalid timing for data bits
                    next_state <= idle;
                end
            end
            finish: begin
                if (success) begin
                    ir_frame_out <= ir_frame_reg;
                    ir_frame_valid <= 1;
                    next_state <= idle;
                end else begin
                    ir_frame_valid <= 0;
                    next_state <= idle;
                end
            end
        end
end
