module thermostat (
  input  wire         i_clk,
  input  wire         i_rst,
  input  wire [5:0]   i_temp_feedback,  // Bit mapping:
                            //   [5] = i_full_cold, [4] = i_medium_cold, [3] = i_low_cold,
                            //   [2] = i_low_hot,   [1] = i_medium_hot, [0] = i_full_hot
  input  wire         i_fan_on,
  input  wire         i_enable,
  input  wire         i_fault,
  input  wire         i_clr,
  output reg          o_heater_full,
  output reg          o_heater_medium,
  output reg          o_heater_low,
  output reg          o_aircon_full,
  output reg          o_aircon_medium,
  output reg          o_aircon_low,
  output reg          o_fan,
  output reg [2:0]    o_state
);

  // Define FSM states
  localparam AMBIENT  = 3'b011;
  localparam HEAT_LOW = 3'b000;
  localparam HEAT_MED = 3'b001;
  localparam HEAT_FULL= 3'b010;
  localparam COOL_LOW = 3'b100;
  localparam COOL_MED = 3'b101;
  localparam COOL_FULL= 3'b110;

  reg [2:0] state;

  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      // Asynchronous reset: force FSM to AMBIENT and all outputs to 0
      state              <= AMBIENT;
      o_heater_full      <= 1'b0;
      o_heater_medium    <= 1'b0;
      o_heater_low       <= 1'b0;
      o_aircon_full      <= 1'b0;
      o_aircon_medium    <= 1'b0;
      o_aircon_low       <= 1'b0;
      o_fan              <= 1'b0;
      o_state            <= AMBIENT;
    end
    else begin
      // Check for fault condition (highest priority override)
      if (i_fault) begin
        // If fault is active, force all outputs to 0.
        // If clear is asserted, set state to AMBIENT on next clock.
        if (i_clr)
          state <= AMBIENT;
        o_heater_full      <= 1'b0;
        o_heater_medium    <= 1'b0;
        o_heater_low       <= 1'b0;
        o_aircon_full      <= 1'b0;
        o_aircon_medium    <= 1'b0;
        o_aircon_low       <= 1'b0;
        o_fan              <= 1'b0;
      end
      // Disable override: if thermostat is disabled, force outputs to 0 and FSM to AMBIENT.
      else if (!i_enable) begin
        state              <= AMBIENT;
        o_heater_full      <= 1'b0;
        o_heater_medium    <= 1'b0;
        o_heater_low       <= 1'b0;
        o_aircon_full      <= 1'b0;
        o_aircon_medium    <= 1'b0;
        o_aircon_low       <= 1'b0;
        o_fan              <= 1'b0;
      end
      // Normal operation: determine next state based on temperature feedback
      else begin
        // Temperature feedback evaluation:
        // Cold conditions (highest priority):
        if (i_temp_feedback[5]) begin
          state <= HEAT_FULL;
        end
        else if (i_temp_feedback[4]) begin
          state <= HEAT_MED;
        end
        else if (i_temp_feedback[3]) begin
          state <= HEAT_LOW;
        end
        // Hot conditions:
        else if (i_temp_feedback[0]) begin
          state <= COOL_FULL;
        end
        else if (i_temp_feedback[1]) begin
          state <= COOL_MED;
        end
        else if (i_temp_feedback[2]) begin
          state <= COOL_LOW;
        end
        // If none of the above, go to AMBIENT.
        else begin
          state <= AMBIENT;
        end

        // Set outputs based on the current state.
        case (state)
          HEAT_FULL: begin
            o_heater_full      <= 1'b1;
            o_heater_medium    <= 1'b0;
            o_heater_low       <= 1'b0;
            o_aircon_full      <= 1'b0;
            o_aircon_medium    <= 1'b0;
            o_aircon_low       <= 1'b0;
          end
          HEAT_MED: begin
            o_heater_full      <= 1'b0;
            o_heater_medium    <= 1'b1;
            o_heater_low       <= 1'b0;
            o_aircon_full      <= 1'b0;
            o_aircon_medium    <= 1'b0;
            o_aircon_low       <= 1'b0;
          end
          HEAT_LOW: begin
            o_heater_full      <= 1'b0;
            o_heater_medium    <= 1'b0;
            o_heater_low       <= 1'b1;
            o_aircon_full      <= 1'b0;
            o_aircon_medium    <= 1'b0;
            o_aircon_low       <= 1'b0;
          end
          COOL_FULL: begin
            o_heater_full      <= 1'b0;
            o_heater_medium    <= 1'b0;
            o_heater_low       <= 1'b0;
            o_aircon_full      <= 1'b1;
            o_aircon_medium    <= 1'b0;
            o_aircon_low       <= 1'b0;
          end
          COOL_MED: begin
            o_heater_full      <= 1'b0;
            o_heater_medium    <= 1'b0;
            o_heater_low       <= 1'b0;
            o_aircon_full      <= 1'b0;
            o_aircon_medium    <= 1'b1;
            o_aircon_low       <= 1'b0;
          end
          COOL_LOW: begin
            o_heater_full      <= 1'b0;
            o_heater_medium    <= 1'b0;
            o_heater_low       <= 1'b0;
            o_aircon_full      <= 1'b0;
            o_aircon_medium    <= 1'b0;
            o_aircon_low       <= 1'b1;
          end
          AMBIENT: begin
            o_heater_full      <= 1'b0;
            o_heater_medium    <= 1'b0;
            o_heater_low       <= 1'b0;
            o_aircon_full      <= 1'b0;
            o_aircon_medium    <= 1'b0;
            o_aircon_low       <= 1'b0;
          end
          default: begin
            o_heater_full      <= 1'b0;
            o_heater_medium    <= 1'b0;
            o_heater_low       <= 1'b0;
            o_aircon_full      <= 1'b0;
            o_aircon_medium    <= 1'b0;
            o_aircon_low       <= 1'b0;
          end
        endcase

        // Fan control: fan on if any heater/aircon output is active OR if manual override (i_fan_on) is asserted.
        if ((state == HEAT_FULL || state == HEAT_MED || state == HEAT_LOW ||
             state == COOL_FULL || state == COOL_MED || state == COOL_LOW) || i_fan_on)
          o_fan <= 1'b1;
        else
          o_fan <= 1'b0;
      end

      // Update the FSM output state.
      o_state <= state;
    end
  end

endmodule