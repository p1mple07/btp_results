module car_parking_system(
    input  logic clk,
    input  logic reset,
    input  logic vehicle_entry_sensor,
    input  logic vehicle_exit_sensor,
    output logic [COUNTER_WIDTH-1:0] available_spaces,
    output logic [COUNTER_WIDTH-1:0] count_car,
    output logic led_status,
    output logic [6:0] seven_seg_display_available_tens,
    output logic [6:0] seven_seg_display_available_units,
    output logic [6:0] seven_seg_display_count_tens,
    output logic [6:0] seven_seg_display_count_units
);

  // Parameters
  parameter TOTAL_SPACES = 12;
  parameter COUNTER_WIDTH = $clog2(TOTAL_SPACES);

  // FSM States
  localparam IDLE   = 2'd0,
             ENTRY  = 2'd1,
             EXIT   = 2'd2,
             FULL   = 2'd3;

  // Internal registers for counters and state
  logic [COUNTER_WIDTH-1:0] avail_spaces_reg;
  logic [COUNTER_WIDTH-1:0] count_car_reg;
  logic [1:0] state;

  // Seven-segment encoding function.
  // Mapping: bit6 = A, bit5 = B, bit4 = C, bit3 = D, bit2 = E, bit1 = F, bit0 = G.
  function automatic logic [6:0] seven_seg_encode(input logic [3:0] digit);
    case(digit)
      4'd0: seven_seg_encode = 7'b1111110; // 0: A,B,C,D,E,F on, G off
      4'd1: seven_seg_encode = 7'b0110000; // 1: B,C on
      4'd2: seven_seg_encode = 7'b1101101; // 2: A,B,D,E,G on
      4'd3: seven_seg_encode = 7'b1111001; // 3: A,B,C,D,G on
      4'd4: seven_seg_encode = 7'b0110011; // 4: B,C,F,G on
      4'd5: seven_seg_encode = 7'b1011011; // 5: A,C,D,F,G on
      4'd6: seven_seg_encode = 7'b1011111; // 6: A,C,D,E,F,G on
      4'd7: seven_seg_encode = 7'b1110000; // 7: A,B,C on
      4'd8: seven_seg_encode = 7'b1111111; // 8: All segments on
      4'd9: seven_seg_encode = 7'b1111011; // 9: A,B,C,D,F,G on
      default: seven_seg_encode = 7'b1111111;
    endcase
  endfunction

  // Internal signals for seven-segment digit extraction
  logic [3:0] avail_tens, avail_units, count_tens, count_units;
  assign avail_tens  = avail_spaces_reg  / 10;
  assign avail_units = avail_spaces_reg  % 10;
  assign count_tens  = count_car_reg     / 10;
  assign count_units = count_car_reg     % 10;

  // Drive seven-segment outputs using the encoding function
  assign seven_seg_display_available_tens  = seven_seg_encode(avail_tens);
  assign seven_seg_display_available_units = seven_seg_encode(avail_units);
  assign seven_seg_display_count_tens      = seven_seg_encode(count_tens);
  assign seven_seg_display_count_units     = seven_seg_encode(count_units);

  // LED status: 1 indicates parking is available (i.e. avail_spaces_reg > 0)
  assign led_status = (avail_spaces_reg != 0) ? 1'b1 : 1'b0;

  // FSM: State register update and counter updates
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state         <= IDLE;
      avail_spaces_reg <= TOTAL_SPACES;
      count_car_reg    <= 0;
    end
    else begin
      case (state)
        IDLE: begin
          // If no spaces are available, go to FULL state.
          if (avail_spaces_reg == 0)
            state <= FULL;
          // If a vehicle is entering and space is available, process entry.
          else if (vehicle_entry_sensor)
            state <= ENTRY;
          // If a vehicle is exiting and at least one car is present, process exit.
          else if (vehicle_exit_sensor && count_car_reg > 0)
            state <= EXIT;
          else
            state <= IDLE;
        end

        ENTRY: begin
          // Decrement available space and increment car count.
          avail_spaces_reg <= avail_spaces_reg - 1;
          count_car_reg    <= count_car_reg + 1;
          state            <= IDLE;
        end

        EXIT: begin
          // Increment available space and decrement car count.
          avail_spaces_reg <= avail_spaces_reg + 1;
          count_car_reg    <= count_car_reg - 1;
          state            <= IDLE;
        end

        FULL: begin
          // In FULL state, if reset then go to IDLE.
          if (reset)
            state <= IDLE;
          // If a vehicle is exiting and at least one car is present, process exit.
          else if (vehicle_exit_sensor && count_car_reg > 0)
            state <= EXIT;
          else
            state <= FULL;
        end

        default: state <= IDLE;
      endcase
    end
  end

  // Drive the output ports from internal registers.
  assign available_spaces = avail_spaces_reg;
  assign count_car        = count_car_reg;

endmodule