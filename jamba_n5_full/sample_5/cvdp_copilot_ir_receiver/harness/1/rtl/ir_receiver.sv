module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    localparam start_bit_period = 2.4;   // 2.4 ms
    localparam data_bit_period   = 0.6;  // 0.6 ms
    localparam bit_width         = 12;  // 12 data bits

    reg [2:0] state;
    reg [2:0] next_state;
    reg started;
    reg decoded;
    reg failed;
    reg success;

    initial begin
        state = idle;
        next_state = idle;
        started   = 0;
        decoded    = 0;
        failed     = 0;
        success    = 0;
    end

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state <= idle;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            idle: begin
                if (reset_in)
                    next_state = idle;
                else
                    if (ir_signal_in == START_BIT_HIGH) begin
                        next_state = start;
                    end else
                        next_state = idle;
                    end
            end

            start: begin
                if (ir_signal_in == START_BIT_LOW && clk_is_high) begin
                    started = 1;
                    next_state = decoding;
                end else
                    next_state = idle;
                end
            end

            decoding: begin
                // Simple validation: assume any bit that is not out‑of‑range is valid
                logic bit;
                for (int i = 0; i < bit_width; i++) begin
                    bit = ir_signal_in;
                    if (bit == IDLE_BIT || bit == DATA_BIT) begin
                        decoded = (bit == IDLE_BIT) ? 0 : 1;
                    end else
                        decoded = 0;
                end

                ir_frame_out = decoded;
                ir_frame_valid = started && (bit_width > 0);

                next_state = finish;
            end

            finish: begin
                state = idle;
                next_state = idle;
            end

        endcase
    end

endmodule
