module
module thermostat (
  input  [5:0] i_temp_feedback,
  input           i_fan_on,
  input           i_enable,
  input           i_fault,
  input           i_clr,
  input           i_clk,
  output reg [2:0] o_state,
  output          o_heater_full,
  output          o_heater_medium,
  output          o_heater_low,
  output          o_aircon_full,
  output          o_aircon_medium,
  output          o_aircon_low,
  output          o_fan
);

  // Define the FSM states
  localparam AMBIENT = 3'd0;
  localparam HEAT_LOW = 3'd1;
  localparam HEAT_MED = 3'd2;
  localparam HEAT_FULL = 3'd3;
  localparam COOL_LOW = 3'd4;
  localparam COOL_MED = 3'd5;
  localparam COOL_FULL = 3'd6;

  // Define the FSM registers
  reg [2:0] fsm_state;
  reg         fsm_reset;
  reg         fsm_fault;
  reg         fsm_clear;
  reg         fsm_enable;

  // Implement the FSM
  always @(posedge i_clk) begin
    case (fsm_state)
      AMBIENT: begin
        if (fsm_fault) begin
          fsm_state <= COOL_FULL;
        end else if (fsm_enable) begin
          if (fsm_clear) begin
            fsm_state <= AMBIENT;
          end else if (fsm_clear) begin
            fsm_state <= AMBIENT;
          end else if (fsm_enable) begin
            fsm_state <= AMBIENT;
          end else begin
            fsm_state <= AMBIENT;
          end
        end else begin
          fsm_state <= AMBIENT;
        end
      end else if (fsm_enable) begin
        fsm_state <= COOL_HIGH;
      end else begin
        fsm_state <= AMBIENT;
      end
    end else begin
      fsm_state <= COOL_HIGH;
    end
  end

  // Implement the output logic
  assign o_fan = fsm_state == COOL_HIGH;
  assign o_heater_low = fsm_state == COOL_HIGH;
  assign o_aircon_low = fsm_state == COOL_HIGH;
  assign o_heater_medium = fsm_state == COOL_HIGH;
  assign o_aircon_medium = fsm_state == COOL_HIGH;
  assign o_fan_on = fsm_state == COOL_HIGH;
  assign o_heater_full = fsm_state == AMBIENT;
  assign o_aircon_full = fsm_state == AMBIENT;
  assign o_fan_on = fsm_state == AMBIENT.
endmodule