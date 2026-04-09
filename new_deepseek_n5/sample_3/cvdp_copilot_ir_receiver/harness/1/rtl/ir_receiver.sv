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
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idle: begin
                // Start bit detection
                if (!reset_in) begin
                    if (ir_signal_in && (!clkin || (cycle_counter == 0))) begin
                        // 2.4ms high pulse detected
                        bit_counter = 0;
                        started = true;
                    end
                end
                next_state = start;
            end

            start: begin
                if (started) begin
                    if (bit_counter == 12) begin
                        // All 12 bits received
                        ir_frame_reg = stored;
                        decoded = true;
                        next_state = finish;
                    end else begin
                        // Check current bit
                        logic current_bit;
                        if (ir_signal_in) begin
                            // High pulse detected after low pulse
                            current_bit = 1;
                        end else begin
                            current_bit = 0;
                        end
                        if (current_bit == 0) begin
                            // 0.6ms high pulse
                            if (clkin) begin
                                // Valid 0 bit
                                stored = (stored << 1) | 0;
                                bit_counter = bit_counter + 1;
                                next_state = start;
                            end else begin
                                // Invalid bit
                                started = false;
                                failed = true;
                                next_state = idle;
                            end
                        end else begin
                            // 1.2ms high pulse
                            if (clkin) begin
                                // Valid 1 bit
                                stored = (stored << 1) | 1;
                                bit_counter = bit_counter + 1;
                                next_state = start;
                            end else begin
                                // Invalid bit
                                started = false;
                                failed = true;
                                next_state = idle;
                            end
                        end
                    end
                end
                next_state = idle;
            end

            decoding: begin
                // Already in decoding state
                next_state = decoding;
            end

            finish: begin
                // Frame complete
                ir_frame_valid = 1;
                next_state = idle;
            end
        end
    end

    wire (
        cycle_counter = (posedge clk_in) ? (posedge clk_in ? 0 : cycle_counter + 1) : 0
    );
    wire (
        bit_counter = (posedge clk_in) ? (posedge clk_in ? 0 : bit_counter + 1) : 0
    );

    initial begin
        // Initial state
        present_state = idle;
        next_state = start;
    end
endmodule