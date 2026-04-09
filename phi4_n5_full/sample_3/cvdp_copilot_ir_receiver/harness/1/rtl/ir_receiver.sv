rtl/ir_receiver.sv
------------------------------------------------------------
module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // IR input signal
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Frame valid signal (1 cycle latency)
);

   //-------------------------------------------------------------------------
   // Parameters: pulse durations in clock cycles (clk = 10us)
   //-------------------------------------------------------------------------
   parameter START_PULSE_CYCLES = 240; // 2.4 ms / 10us
   parameter LOW_PULSE_CYCLES   = 6;   // 0.6 ms / 10us
   parameter HIGH_PULSE_ZERO    = 6;   // 0.6 ms for bit 0
   parameter HIGH_PULSE_ONE     = 12;  // 1.2 ms for bit 1

   //-------------------------------------------------------------------------
   // State Machine Declaration
   //-------------------------------------------------------------------------
   typedef enum logic [1:0] {idle, start, decoding, finish} ir_state;
   ir_state present_state, next_state;

   //-------------------------------------------------------------------------
   // Counters and Flags
   //-------------------------------------------------------------------------
   // cycle_counter: counts cycles for the current pulse (start or data bit)
   int cycle_counter;
   // bit_counter: counts the number of data bits decoded (0 to 11)
   int bit_counter;
   // low_pulse: flag indicating which phase of a data bit is being measured.
   //   = 1: expecting the low pulse (0.6 ms)
   //   = 0: expecting the high pulse (0.6 or 1.2 ms)
   logic low_pulse;

   //-------------------------------------------------------------------------
   // Register to store the decoded 12-bit frame.
   // The first decoded bit becomes bit0 (LSB) and the last becomes bit11 (MSB).
   //-------------------------------------------------------------------------
   logic [11:0] ir_frame_reg;

   //-------------------------------------------------------------------------
   // Output register (1-cycle latency)
   //-------------------------------------------------------------------------
   logic [11:0] frame_out_reg;
   logic valid_reg;

   //-------------------------------------------------------------------------
   // Combinational Logic: Next State Determination
   //-------------------------------------------------------------------------
   always_comb begin
      next_state = present_state; // default

      case (present_state)
         idle: begin
            if (ir_signal_in)
               next_state = start;
            else
               next_state = idle;
         end
         start: begin
            if (ir_signal_in) begin
               if (cycle_counter == START_PULSE_CYCLES - 1)
                  next_state = decoding;
               else
                  next_state = start;
            end else begin
               // Start pulse ended early: invalid start condition.
               next_state = idle;
            end
         end
         decoding: begin
            if (low_pulse) begin
               // Expecting low pulse for a data bit.
               if (!ir_signal_in) begin
                  if (cycle_counter == LOW_PULSE_CYCLES - 1)
                     next_state = decoding; // Completed low pulse; switch to high pulse phase.
                  else
                     next_state = decoding;
               end else begin
                  // Error: expected low but got high.
                  next_state = idle;
               end
            end else begin
               // Expecting high pulse for a data bit.
               if (ir_signal_in) begin
                  if ((cycle_counter == HIGH_PULSE_ZERO - 1) || (cycle_counter == HIGH_PULSE_ONE - 1))
                     next_state = decoding; // Completed high pulse; latch bit and prepare for next bit.
                  else
                     next_state = decoding;
               end else begin
                  // Error: expected high but got low.
                  next_state = idle;
               end
            end

            // If all 12 bits have been received, transition to finish state.
            if ((present_state == decoding) && (!low_pulse) && (bit_counter == 11))
               next_state = finish;
         end
         finish: begin
            next_state = idle;
         end
         default: next_state = idle;
      endcase
   end

   //-------------------------------------------------------------------------
   // Sequential Logic: State, Counter, and Flag Updates
   //-------------------------------------------------------------------------
   always_ff @(posedge clk_in or posedge reset_in) begin
      if (reset_in) begin
         present_state <= idle;
         cycle_counter <= 0;
         bit_counter   <= 0;
         low_pulse     <= 1; // In decoding state, start by expecting the low pulse.
         ir_frame_reg  <= 12'd0;
      end else begin
         present_state <= next_state;

         case (present_state)
            idle: begin
               cycle_counter <= 0;
               bit_counter   <= 0;
               low_pulse     <= 1;
               ir_frame_reg  <= 12'd0;
            end
            start: begin
               if (ir_signal_in)
                  cycle_counter <= cycle_counter + 1;
               else
                  cycle_counter <= 0; // Error: reset counter.
            end
            decoding: begin
               if (low_pulse) begin
                  // ---- Low pulse phase ----
                  if (!ir_signal_in) begin
                     if (cycle_counter == LOW_PULSE_CYCLES - 1) begin
                        cycle_counter <= 0; // Reset counter for high pulse.
                        low_pulse     <= 0; // Switch to high pulse phase.
                     end else begin
                        cycle_counter <= cycle_counter + 1;
                     end
                  end else begin
                     cycle_counter <= 0; // Error condition.
                  end
               end else begin
                  // ---- High pulse phase ----
                  if (ir_signal_in) begin
                     if ((cycle_counter == HIGH_PULSE_ZERO - 1) || (cycle_counter == HIGH_PULSE_ONE - 1)) begin
                        // Latch the bit: if high pulse equals HIGH_PULSE_ONE then bit = 1, else 0.
                        ir_frame_reg[bit_counter] <= (cycle_counter == HIGH_PULSE_ONE - 1) ? 1'b1 : 1'b0;
                        bit_counter <= bit_counter + 1;
                        // After latching, if not all bits received, prepare for next bit.
                        if (bit_counter < 11) begin
                           low_pulse <= 1;
                           cycle_counter <= 0;
                        end else begin
                           // All 12 bits received; remain in decoding (low_pulse stays 0)
                           low_pulse <= 0;
                        end
                     end else begin
                        cycle_counter <= cycle_counter + 1;
                     end
                  end else begin
                     cycle_counter <= 0; // Error condition.
                  end
               end
            end
            finish: begin
               // No counter updates in finish state.
            end
            default: cycle_counter <= 0;
         endcase
      end
   end

   //-------------------------------------------------------------------------
   // Output Register Logic: 1-cycle latency for decoded frame.
   //-------------------------------------------------------------------------
   always_ff @(posedge clk_in or posedge reset_in) begin
      if (reset_in) begin
         frame_out_reg <= 12'd0;
         valid_reg     <= 1'b0;
      end else begin
         case (present_state)
            finish: begin
               frame_out_reg <= ir_frame_reg;
               valid_reg     <= 1'b1;
            end