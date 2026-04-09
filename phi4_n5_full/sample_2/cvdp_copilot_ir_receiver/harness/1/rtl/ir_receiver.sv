module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input IR signal
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

  // Timing parameters (in clock cycles)
  localparam integer START_BIT_DURATION     = 240;  // 2.4ms / 10us
  localparam integer BIT_LOW_DURATION       = 60;   // 0.6ms / 10us
  localparam integer BIT_ZERO_HIGH_DURATION = 60;   // 0.6ms / 10us
  localparam integer BIT_ONE_HIGH_DURATION  = 120;  // 1.2ms / 10us
  localparam integer DATA_BITS              = 12;

  typedef enum logic [1:0] {idle, start, decoding, finish} ir_state;
  ir_state present_state, next_state;

  // Internal signals for timing and bit counting
  int cycle_counter; 
  int bit_counter;           
  logic low_phase;            // true: waiting for low pulse of current bit, false: waiting for high pulse

  // Register to store decoded bits (LSB first)
  logic [11:0] ir_frame_reg; 

  // Internal register for output valid signal
  logic ir_frame_valid_reg;

  // Synchronous process: state machine and register updates
  always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
      present_state      <= idle;
      cycle_counter      <= 0;
      bit_counter        <= 0;
      low_phase          <= 1;
      ir_frame_reg       <= 12'b0;
      ir_frame_valid_reg <= 0;
      ir_frame_valid     <= 0;
      ir_frame_out       <= 12'b0;
    end
    else begin
      case (present_state)
        idle: begin
          // Wait for start bit: IR signal must be high for START_BIT_DURATION cycles
          if (ir_signal_in) begin
            cycle_counter <= cycle_counter + 1;
            if (cycle_counter == START_BIT_DURATION)
              next_state <= start;
            else
              next_state <= idle;
          end
          else begin
            // If signal goes low before start condition, reset timer
            cycle_counter <= 0;
            next_state <= idle;
          end
        end

        start: begin
          // After start pulse, wait for falling edge to begin decoding
          if (!ir_signal_in) begin
            bit_counter   <= 0;
            low_phase     <= 1;  // start with low pulse for first data bit
            cycle_counter <= 0;
            next_state    <= decoding;
          end
          else begin
            // If still high, invalid start condition, go back to idle
            next_state <= idle;
          end
        end

        decoding: begin
          if (low_phase) begin
            // Measure the low pulse duration for the current bit (should be BIT_LOW_DURATION cycles)
            if (cycle_counter < BIT_LOW_DURATION) begin
              cycle_counter <= cycle_counter + 1;
              next_state    <= decoding;
            end
            else begin
              // Low pulse complete, switch to high phase
              low_phase     <= 0;
              cycle_counter <= 0;
              next_state    <= decoding;
            end
          end
          else begin
            // High pulse phase: measure duration to determine bit value
            if (cycle_counter < BIT_ZERO_HIGH_DURATION) begin
              cycle_counter <= cycle_counter + 1;
              next_state    <= decoding;
            end
            else if (cycle_counter == BIT_ZERO_HIGH_DURATION) begin
              // Bit is 0
              ir_frame_reg <= {ir_frame_reg, 1'b0};
              bit_counter  <= bit_counter + 1;
              if (bit_counter == DATA_BITS - 1)
                next_state <= finish;
              else begin
                low_phase   <= 1;  // next bit, start low phase
                cycle_counter <= 0;
                next_state   <= decoding;
              end
            end
            else if (cycle_counter == BIT_ONE_HIGH_DURATION) begin
              // Bit is 1
              ir_frame_reg <= {ir_frame_reg, 1'b1};
              bit_counter  <= bit_counter + 1;
              if (bit_counter == DATA_BITS - 1)
                next_state <= finish;
              else begin
                low_phase   <= 1;
                cycle_counter <= 0;
                next_state   <= decoding;
              end
            end
            else begin
              // Invalid high pulse duration: reset and wait for next valid frame
              next_state <= idle;
            end
          end
        end

        finish: begin
          // Output the decoded frame for one clock cycle
          ir_frame_valid_reg <= 1;
          ir_frame_out       <= ir_frame_reg;
          next_state         <= idle;
        end

        default: next_state <= idle;
      endcase
    end

    // Update present state at the end of the clock cycle
    present_state <= next_state;
    // Drive output valid signal
    ir_frame_valid <= ir_frame_valid_reg;
  end

endmodule