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
                // Reset outputs
                ir_frame_valid <= 0;
                ir_frame_out   <= 0;

                // Check for valid start condition
                if (!started && ir_signal_in) begin
                    started <= 1;
                    bit_counter <= 0;
                    cycle_counter <= 0;

                    // Check timing of first bit
                    if (cycle_counter > 2) begin
                        next_state <= start;
                    end else begin
                        next_state <= idle;
                    end
                end else begin
                    next_state <= idle;
                end
            end

            start: begin
                // Check for valid start bit
                if (ir_signal_in) begin
                    next_state <= decoding;
                    bit_counter <= 0;
                    cycle_counter <= 0;
                    started <= 1;
                end else begin
                    next_state <= idle;
                end
            end

            decoding: begin
                // Decode each bit based on its timing
                if ((bit_counter == 0 || bit_counter == 6 || bit_counter == 12) && ir_signal_in) begin
                    bit_counter <= bit_counter + 1;
                    if (bit_counter == 12) begin
                        // Store the decoded frame
                        ir_frame_reg <= ir_frame_out << 1;
                        ir_frame_out   <= {1'b0, ir_frame_reg};
                        stored <= 1;

                        // Check for end of frame
                        if (ir_frame_reg[11]) begin
                            next_state <= finish;
                        end else begin
                            next_state <= decoding;
                        }
                    end
                end else begin
                    next_state <= idle;
                end
            end

            finish: begin
                // Reset outputs
                ir_frame_valid <= 0;
                ir_frame_out   <= 0;

                // Check for a valid frame
                if (stored) begin
                    // Calculate checksum
                    // Check against expected value
                    // Set ir_frame_valid accordingly
                    if ( /* checksum calculation */) begin
                        next_state <= finish;
                    end else begin
                        next_state <= idle;
                    end
                end else begin
                    next_state <= idle;
                end
            end

            default: begin
                next_state <= idle;
            end
        endcase
    end

endmodule