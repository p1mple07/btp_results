module thermostat(
    input wire i_clk,
    input wire i_rst,
    input wire i_enable,
    input wire i_fault,
    input wire i_clr,
    input wire [5:0] i_temp_feedback[5:0],
    output reg o_heater_full,
    output reg o_heater_medium,
    output reg o_heater_low,
    output reg o_aircon_full,
    output reg o_aircon_medium,
    output reg o_aircon_low,
    output reg o_fan,
    output reg [2:0] o_state[2:0]
);
