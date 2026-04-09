module car_parking_system (
    input  logic         clk,
    input  logic         reset,
    input  logic         vehicle_entry_sensor,
    input  logic         vehicle_exit_sensor,
    output logic [3:0]   available_spaces,  // 4 bits to cover numbers 0 to 12
    output logic [3:0]   count_car,
    output logic         led_status,
    output logic [6:0]   seven_seg_display_available_tens,
    output logic [6:0]   seven_seg_display_available_units,
    output logic [6:0]   seven_seg_display_count_tens,
    output logic [6:0]   seven_seg_display_count_units
);

  // Parameter definitions
  parameter TOTAL_SPACES = 12;
  parameter SPACES_WIDTH = 4;  // Enough to represent numbers 0 to TOTAL_SPACES

  // FSM state encoding
  localparam [1:0] STATE_IDLE    = 2'b00,
                    STATE_ENTRY   = 2'b01,
                    STATE_EXIT    = 2'b10,
                    STATE_FULL    = 2'b11;

  // FSM state registers
  logic [1:0] state, next_state;

  // Function: Convert a digit (0-9) to its 7-segment encoding.
  // Bit mapping: MSB = segment A, LSB = segment G.
  function automatic logic [6:0] digit_to_7seg;
    input int digit;
    case (digit)
      0: digit_to_7seg = 7'b0111111; // 0: A,B,C,D,E,F on, G off
      1: digit_to_7seg = 7'b0000110; // 1: B,C on
      2: digit_to_7seg = 7'b1011011; // 2: A, B, G, E, D on
      3: digit_to_7seg = 7'b1001111; // 3: A, B, C, D, G on
      4: digit_to_7seg = 7'b1100110; // 4: F, G, B, C on
      5: digit_to_7seg = 7'b1101101; // 5: F, G, C, D, A on
      6: digit_to_7seg = 7'b1111101; // 6: F, G, E, D, C, A on
      7: digit_to_7seg = 7'b0000111; // 7: A, B, C on
      8: digit_to_7seg = 7'b1111111; // 8: All segments on
      9: digit_to_7seg = 7'b1101111; // 9: F, G, E, D, C, A on
      default: digit_to_7seg = 7'b0000000;
    endcase
  endfunction

  // Sequential process: FSM state transitions and register updates.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      available_spaces <= TOTAL_SPACES;
      count_car        <= 0;
      state            <= STATE_IDLE;
    end else begin
      // Update state register with next state.
      state <= next_state;
      // Update parking counters based on current state.
      case (state)
        STATE_IDLE: begin
          // No update in Idle.
        end
        STATE_ENTRY: begin
          // Vehicle entry processing: decrement available_spaces, increment count_car.
          available_spaces <= available_spaces - 1;
          count_car        <= count_car + 1;
        end
        STATE_EXIT: begin
          // Vehicle exit processing: increment available_spaces, decrement count_car.
          available_spaces <= available_spaces + 1;
          count_car        <= count_car - 1;
        end
        STATE_FULL: begin
          // In Full state, no update occurs until a valid exit event.
        end
        default: begin
          // No update.
        end
      endcase
    end
  end

  // Combinational process: Determine next FSM state.
  always_comb begin
    // Default: hold current state.
    next_state = state;
    case (state)
      STATE_IDLE: begin
        if (vehicle_entry_sensor) begin
          if (available_spaces != 0)
            next_state = STATE_ENTRY;
          else
            next_state = STATE_FULL;
        end else if (vehicle_exit_sensor) begin
          if (count_car != 0)
            next_state = STATE_EXIT;
        end
      end
      STATE_ENTRY: begin
        // After processing entry, return to Idle.
        next_state = STATE_IDLE;
      end
      STATE_EXIT: begin
        // After processing exit, return to Idle.
        next_state = STATE_IDLE;
      end
      STATE_FULL: begin
        // Remain in Full unless a valid exit occurs.
        if (vehicle_exit_sensor && count_car != 0)
          next_state = STATE_EXIT;
      end
      default: next_state = STATE_IDLE;
    endcase
  end

  // LED status: High when parking is available (available_spaces > 0), low when full.
  assign led_status = (available_spaces != 0);

  // Combinational process: Convert available_spaces and count_car to 7-segment display values.
  // Compute tens and units digits for each.
  integer available_spaces_int, count_car_int;
  integer tens_available, ones_available, tens_car, ones_car;

  always_comb begin
    // Convert register values to integer.
    available_spaces_int = available_spaces;
    count_car_int        = count_car;

    // Determine tens and ones for available_spaces.
    if (available_spaces_int < 10) begin
      tens_available = 0;
      ones_available = available_spaces_int;
    end else begin
      tens_available = available_spaces_int / 10;
      ones_available = available_spaces_int % 10;
    end

    // Determine tens and ones for count_car.
    if (count_car_int < 10) begin
      tens_car = 0;
      ones_car = count_car_int;
    end else begin
      tens_car = count_car_int / 10;
      ones_car = count_car_int % 10;
    end

    seven_seg_display_available_tens  = digit_to_7seg(tens_available);
    seven_seg_display_available_units = digit_to_7seg(ones_available);
    seven_seg_display_count_tens      = digit_to_7seg(tens_car);
    seven_seg_display_count_units     = digit_to_7seg(ones_car);
  end

endmodule