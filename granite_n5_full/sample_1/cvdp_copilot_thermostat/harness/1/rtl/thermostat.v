module thermostat (
    input [5:0] i_temp_feedback,
    input i_fan_on,
    input i_enable,
    input i_fault,
    input i_clr,
    input i_clk,
    output reg o_heater_full,
    output reg o_heater_medium,
    output reg o_heater_low,
    output reg o_aircon_full,
    output reg o_aircon_medium,
    output reg o_aircon_low,
    output reg o_fan,
    output reg [2:0] o_state
);

  //... (rest of the code goes here)

endmodule