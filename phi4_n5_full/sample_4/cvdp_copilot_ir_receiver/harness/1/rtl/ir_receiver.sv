module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    // State machine states: idle, start, decoding, finish
    typedef enum logic [1:0] {idle, start, decoding, finish} ir_state;
    ir_state present_state, next_state;

    // (Other control signals, not used directly in this implementation)
    logic started; 
    logic decoded; 
    logic failed; 
    logic success;

    // Counters used for timing measurements (in clock cycles)
    int cycle_counter; 
    int bit_counter;          

    // Register to store the decoded frame bits (LSB first)
    logic [11:0] ir_frame_reg; 
    logic stored;                       

    // Additional signals to track which pulse phase we are in for data bits
    logic in_low_pulse;
    logic in_high_pulse;

    // State register update: on reset go to idle, else follow next_state
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    // Main state machine: handles start pulse and 12 data bits measurement
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            present_state      <= idle;
            cycle_counter      <= 0;
            bit_counter        <= 0;
            ir_frame_reg       <= 12'd0;
            in_low_pulse       <= 1'b0;
            in_high_pulse      <= 1'b0;
            ir_frame_valid     <= 1'b0;
        end else begin
            case (present_state)
                // ------------------------------------------------------------------
                // Idle: Wait for a valid start pulse (2.4ms = 240 cycles)
                // ------------------------------------------------------------------
                idle: begin
                    if (ir_signal_in) begin
                        if (cycle_counter < 240) begin
                            cycle_counter <= cycle_counter + 1;
                        end else begin
                            // Valid start pulse detected; transition to start state.
                            present_state <= start;
                            cycle_counter <= 0;
                            bit_counter  <= 0;
                            in_low_pulse <= 1'b1;  // Prepare to measure the low pulse of the first data bit.
                        end
                    end else begin
                        // If signal goes low before 240 cycles, reset counter.
                        cycle_counter <= 0;
                    end
                end

                // ------------------------------------------------------------------
                // Start: Measure the low pulse for the first data bit (0.6ms = 60 cycles)
                // ------------------------------------------------------------------
                start: begin
                    if (!ir_signal_in) begin
                        if (cycle_counter < 60) begin
                            cycle_counter <= cycle_counter + 1;
                        end else if (cycle_counter == 60) begin
                            // Valid low pulse for first bit; now expect the high pulse.
                            present_state <= decoding;
                            in_low_pulse  <= 1'b0;
                            in_high_pulse <= 1'b1;
                            cycle_counter <= 0;
                        end else begin
                            // Low pulse duration invalid; reset.
                            present_state <= idle;
                            cycle_counter <= 0;
                            bit_counter  <= 0;
                            ir_frame_reg <= 12'd0;
                            in_low_pulse <= 1'b0;
                            in_high_pulse<= 1'b0;
                        end
                    end
                end

                // ------------------------------------------------------------------
                // Decoding: For each data bit, measure low pulse then high pulse.
                // Each data bit consists of:
                //   - Low pulse: 0.6ms (60 cycles)
                //   - High pulse: 0.6ms (60 cycles) for bit 0, or 1.2ms (120 cycles) for bit 1.
                // Bits are stored LSB first.
                // ------------------------------------------------------------------
                decoding: begin
                    if (in_low_pulse) begin
                        // Measure the low pulse of the current data bit.
                        if (ir_signal_in) begin
                            if (cycle_counter < 60) begin
                                cycle_counter <= cycle_counter + 1;
                            end else if (cycle_counter == 60) begin
                                // Valid low pulse; now prepare to measure the high pulse.
                                in_low_pulse  <= 1'b0;
                                in_high_pulse <= 1'b1;
                                cycle_counter <= 0;
                            end else begin
                                // Low pulse duration invalid; reset.
                                present_state <= idle;
                                cycle_counter <= 0;
                                bit_counter  <= 0;
                                ir_frame_reg <= 12'd0;
                                in_low_pulse <= 1'b0;
                                in_high_pulse<= 1'b0;
                            end
                        end
                    end else if (in_high_pulse) begin
                        // Measure the high pulse of the current data bit.
                        if (ir_signal_in) begin
                            if (cycle_counter < 120) begin
                                cycle_counter <= cycle_counter + 1;
                            end else if ((cycle_counter == 60) || (cycle_counter == 120)) begin
                                // Valid high pulse detected; determine the bit value.
                                if (cycle_counter == 60) begin
                                    // 0 bit: low pulse (60 cycles) followed by high pulse (60 cycles)
                                    ir_frame_reg[bit_counter] <= 1'b0;
                                end else begin
                                    // 1 bit: low pulse (60 cycles) followed by high pulse (120 cycles)
                                    ir_frame_reg[bit_counter] <= 1'b1;
                                end
                                // Move to the next bit.
                                if (bit_counter < 11) begin
                                    bit_counter <= bit_counter + 1;
                                end else begin
                                    // Last bit received; transition to finish state.
                                    present_state <= finish;
                                end
                                // Prepare for the next data bit's low pulse.
                                in_low_pulse  <= 1'b1;
                                in_high_pulse <= 1'b0;
                                cycle_counter <= 0;
                            end else begin
                                // High pulse duration invalid; reset.
                                present_state <= idle;
                                cycle_counter <= 0;
                                bit_counter  <= 0;
                                ir_frame_reg <= 12'd0;
                                in_low_pulse <= 1'b0;
                                in_high_pulse<= 1'b0;
                            end
                        end else begin
                            // If the signal goes low during the high pulse, it is invalid.
                            present_state <= idle;
                            cycle_counter <= 0;
                            bit_counter  <= 0;
                            ir_frame_reg <= 12'd0;
                            in_low_pulse <= 1'b0;
                            in_high_pulse<= 1'b0;
                        end
                    end
                end

                // ------------------------------------------------------------------
                // Finish: Output the decoded frame and valid signal for one clock cycle.
                // ------------------------------------------------------------------
                finish: begin
                    ir_frame_out  <= ir_frame_reg;
                    ir_frame_valid<= 1'b1;
                    // After one cycle, return to idle and clear the valid signal.
                    present_state <= idle;
                    ir_frame_valid<= 1'b0;
                end

                default: begin
                    present_state <= idle;
                end
            endcase
        end
    end

    // Next state logic (if additional combinational logic is required).
    // For this implementation the sequential always_ff block handles state transitions.
    always_comb begin
        next_state = present_state; // Default: hold current state.
        // Additional combinational logic can be added here if needed.
    end

endmodule