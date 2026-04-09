module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    typedef enum logic [1:0] { idle, start, decoding, done } ir_state;
    ir_state present_state, next_state;

    logic started;
    logic decoded;
    logic failed;
    logic success;

    integer cycle_counter;
    integer bit_counter;

    logic [11:0] ir_frame_reg;

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idles;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idles: begin
                if (reset_in)
                    next_state <= idles;
                else
                    next_state <= start;
            end

            start: begin
                // Assume start_bit_valid is provided externally
                if (start_bit_valid) begin
                    next_state <= decoding;
                end else
                    next_state <= idle;
                end
            end

            decoding: begin
                // Process each bit: for simplicity, assume all valid
                // In real code, we would check each bit timing.
                // For now, just set decoded to 1 after 12 bits.
                // We'll output a placeholder.
                next_state <= done;
            end

            done: begin
                // After decoding, set output
                ir_frame_out = ir_frame_reg;
                ir_frame_valid = true;
                decoded = true;
                success = true;
            end

            fail: begin
                ir_frame_out = 32'hFFFF;
                ir_frame_valid = false;
                success = false;
            end
        endcase
    end

endmodule
