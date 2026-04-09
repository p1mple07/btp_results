// File: rtl/car_parking_system.sv
module car_parking_system (
  input  logic         clk,
  input  logic         reset,
  input  logic         vehicle_entry_sensor,
  input  logic         vehicle_exit_sensor,
  output logic [3:0]   available_spaces,  // Using 4 bits for TOTAL_SPACES (>=12)
  output logic [3:0]   count_car,
  output logic         led_status,
  output logic [6:0]   seven_seg_display_available_tens,
  output logic [6:0]   seven_seg_display_available_units,
  output logic [6:0]   seven_seg_display_count_tens,
  output logic [6:0]   seven_seg_display_count_units
);

  // Parameters
  parameter TOTAL_SPACES = 12;
  parameter COUNTER_WIDTH = 4;  // 4 bits are sufficient to represent numbers 0 to 15

  // FSM state encoding
  typedef enum logic [1:0] {
    IDLE            = 2'd0,
    ENTRY_PROCESS   = 2'd1,
    EXIT_PROCESS    = 2'd2,
    FULL            = 2'd3
  } state_t;

  // Registers for FSM state and counters
  state_t state, next_state;
  logic [COUNTER_WIDTH-1:0] next_count_car;
  logic [COUNTER_WIDTH-1:0] next_available_spaces;

  //-------------------------------------------------------------------------
  // Next-state logic and counter updates (combinational)
  //-------------------------------------------------------------------------
  always_comb begin
    // Default assignments
    next_state            = state;
    next_count_car        = count_car;
    next_available_spaces = available_spaces;

    case (state)
      IDLE: begin
        if (vehicle_exit_sensor)
          next_state = EXIT_PROCESS;
        else if (vehicle_entry_sensor)
          next_state = (count_car == TOTAL_SPACES) ? FULL : ENTRY_PROCESS;
        // else remain in IDLE
      end

      ENTRY_PROCESS: begin
        // Vehicle entering: increment car count and update available spaces
        next_count_car        = count_car + 1;
        next_available_spaces = TOTAL_SPACES - next_count_car;
        // If parking becomes full after entry, transition to FULL state
        next_state = (next_count_car == TOTAL_SPACES) ? FULL : IDLE;
      end

      EXIT_PROCESS: begin
        // Vehicle exiting: decrement car count (ensure non-negative) and update available spaces
        next_count_car        = (count_car > 0) ? count_car - 1 : 0;
        next_available_spaces = TOTAL_SPACES - next_count_car;
        next_state = IDLE;
      end

      FULL: begin
        if (vehicle_exit_sensor) begin
          // Exit processing when full: decrement car count and update available spaces
          next_count_car        = (count_car > 0) ? count_car - 1 : 0;
          next_available_spaces = TOTAL_SPACES - next_count_car;
          next_state = IDLE;
        end
        // If entry sensor is high in FULL state, remain in FULL (entry denied)
      end
    endcase
  end

  //-------------------------------------------------------------------------
  // Synchronous update of FSM state and counters
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state             <= IDLE;
      count_car         <= 0;
      available_spaces  <= TOTAL_SPACES;
    end
    else begin
      state             <= next_state;
      count_car         <= next_count_car;
      available_spaces  <= next_available_spaces;
    end
  end

  //-------------------------------------------------------------------------
  // Seven-segment display decoder function
  // Mapping: MSB = segment A, LSB = segment G.
  //-------------------------------------------------------------------------
  function automatic [6:0] decode_digit(input [3:0] digit);
    case (digit)
      4'd0: decode_digit = 7'b1111110;  // 0: A,B,C,D,E,F on, G off