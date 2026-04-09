module thermostat (
  // Input signals
  input [5:0] i_temp_feedback,
  input        i_fan_on,
  input        i_enable,
  input        i_fault,
  input        i_clr,
  input        i_clk,
  // Output signals
  output       o_heater_full,
  output       o_heater_medium,
  output       o_heater_low,
  output       o_aircon_full,
  output       o_aircon_medium,
  output       o_aircon_low,
  output       o_fan,
  // FSM Output State (3-bit)
  output [2:0] o_state
);

  // Define your internal state machine here.
  enum {
    AMBIENT,
    HEAT_FULL,
    HEAT_MED,
    HEAT_LOW,
    COOL_LOW,
    COOL_MED,
    COOL_FULL
  } state;

  always @(posedge i_clk or posedge i_rst or posedge i_fault or posedge i_enable) begin
    case (state)
      AMBIENT: begin
        // Implement the default behavior for the ambient state here.
        //...
      end
      HEAT_FULL: begin
        // Implement the behavior for the full heat state here.
        //...
      end
      HEAT_MED: begin
        // Implement the behavior for the medium heat state here.
        //...
      end
      HEAT_LOW: begin
        // Implement the behavior for the low heat state here.
        //...
      end
      COOL_LOW: begin
        // Implement the behavior for the low cool state here.
        //...
      end
      COOL_MED: begin
        // Implement the behavior for the medium cool state here.
        //...
      end
      COOL_FULL: begin
        // Implement the behavior for the full cool state here.
        //...
      end
    endcase
  end

  assign o_heater_full = (state == FULL_HEATER)?
    // Implement the assign statement for o_heater_full here.
    //...
  end

  assign o_heater_medium = (state == FULL_HEATER)?
    // Implement the assign statement for o_heater_medium here.
    //...
  end

  assign o_heater_low = (state == FULL_HEATER)?
    // Implement the assign statement for o_heater_low here.
    //...
  end

  assign o_aircon_full = (state == COOL_AIRCON)?
    // Implement the assign statement for o_aircon_full here.
    //...
  end

  assign o_aircon_medium = (state == COOL_AIRCON)?
    // Implement the assign statement for o_aircon_medium here.
    //...
  end

  assign o_aircon_low = (state == COOL_AIRCON)?
    // Implement the assign statements for o_aircon_low here.
    //...
  end

  assign o_fan = (state == FULL_HEATER)?
    // Implement the assign statements for o_fan here.
    //...
  end

  module dut.sv
endmodule