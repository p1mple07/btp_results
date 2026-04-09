module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    typedef enum logic [1:0] {idle, start, decoding, finish} ir_state;
    ir_state present_state, next_state;

    logic started; 
    logic decoded; 
    logic failed; 
    logic success;

    int cycle_counter; 
    int bit_counter;          

    logic [11:0] ir_frame_reg; 
    logic stored;                       

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            present_state <= idle;
            cycle_counter <= 0;
            bit_counter <= 0;
            ir_frame_reg <= 0;
            stored <= 0;
            failed <= 0;
            success <= 0;
        end
        else begin
            present_state <= next_state;
            cycle_counter <= cycle_counter + 1;

            if (present_state == start && cycle_counter == 2) begin
                decoded <= 0;
                stored <= 0;
                bit_counter <= 0;
                success <= 1;
                ir_frame_reg <= 0;
                failed <= 0;
            end
            else if (present_state == decoding && bit_counter < 12) begin
                if (ir_signal_in == 1'b0)
                    bit_counter <= bit_counter + 1;
                else begin
                    bit_counter <= bit_counter + 2;
                    decoded <= 1;
                    stored <= 1;
                end

                if (cycle_counter >= 9 && bit_counter == 12) begin
                    next_state <= finish;
                end
                else if (cycle_counter >= 17 && bit_counter == 12) begin
                    next_state <= finish;
                end
                else 
                    next_state <= decoding;
            end
            else if (present_state == finish && cycle_counter > 17) begin
                next_state <= idle;
            end
            else 
                next_state <= idle;

        end
    end

    always_comb begin
        case (present_state)
            idle: begin
                if (started && ir_signal_in == 1'b0) begin
                    if (cycle_counter == 2) 
                        next_state <= start;
                    else 
                        next_state <= idle;
                end
                else 
                    next_state <= idle;
            end

            start: begin
                if (decoded && ir_signal_in == 1'b1) begin
                    if (bit_counter < 12)
                        next_state <= decoding;
                    else 
                        next_state <= idle;
                end
                else 
                    next_state <= start;
            end

            decoding: begin
                if (decoded && ir_signal_in == 1'b0) begin
                    if (bit_counter < 12)
                        next_state <= decoding;
                    else 
                        next_state <= idle;
                end
                else if (!stored && ir_signal_in == 1'b1) begin
                    if (bit_counter == 12) 
                        next_state <= finish;
                    else 
                        next_state <= decoding;
                end
                else if (failed && ir_signal_in == 1'b1) begin
                    if (bit_counter < 12)
                        next_state <= decoding;
                    else 
                        next_state <= idle;
                end
                else 
                    next_state <= decoding;
            end

            finish: begin
                if (decoded) begin
                    next_state <= idle;
                end
                else 
                    next_state <= idle;
            end

            default: begin
                next_state <= idle;
            end

        endcase
    end

    assign ir_frame_out = ir_frame_reg;
    assign ir_frame_valid = success;

endmodule