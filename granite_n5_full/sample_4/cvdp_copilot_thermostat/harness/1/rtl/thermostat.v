module thermostat (
  input [5:0] i_temp_feedback,
  input        i_fan_on,
  input        i_enable,
  input        i_fault,
  input        i_clr,
  input         clk,
  input         rst,
  output reg   o_heater_full,
  output reg   o_heater_medium,
  output reg   o_heater_low,
  output reg   o_aircon_full,
  output reg   o_aircon_medium,
  output reg   o_aircon_low,
  output reg   o_fan,
  output reg [2:0] o_state
);

  // Define the FSM states
  typedef enum reg {
    AMBIENT,
    HEAT_LOW,
    HEAT_MED,
    HEAT_FULL,
    COOL_LOW,
    COOL_MED,
    COOL_FULL
  } fsm_state;

  // Define the module inputs and outputs
  //...

  // Define the internal signals
  //...

  // Define the FSM state machine
  always @(posedge clk, posedge rst) begin
    if (rst == 1'b1) begin
      // Reset FSM to AMBIENT state and drive outputs to 0.
      //...
    end
    else begin
      // Implement the FSM state machine.
      //...

      // Implement the output logic.
      //...
    end
  end

endmodule