module thermostat (
    input wire i_clk,
    input wire i_rst,
    input wire i_enable,
    input wire i_fault,
    input wire [5:0] i_temp_feedback[5:0],
    input wire i_fan_on,
    output reg o_heater_full, o_heater_medium, o_heater_low,
    output reg o_aircon_full, o_aircon_medium, o_aircon_low,
    output reg o_fan,
    output reg [2:0] o_state[2:0]
);

reg [2:0] state;

always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
        state <= 3'b000;
        o_heater_full <= 0;
        o_heater_medium <= 0;
        o_heater_low <= 0;
        o_aircon_full <= 0;
        o_aircon_medium <= 0;
        o_aircon_low <= 0;
        o_fan <= 0;
        o_state[2:0] <= 3'b000;
    } else begin
        if (i_enable && i_fault == 0) begin
            if (i_temp_feedback[5] == 1)
                state <= 3'b100;
            else if (i_temp_feedback[4] == 1)
                state <= 3'b101;
            else if (i_temp_feedback[3] == 1)
                state <= 3'b110;
            else if (i_temp_feedback[2] == 1)
                state <= 3'b111;
            else if (i_temp_feedback[1] == 1)
                state <= 3'b011;
            else if (i_temp_feedback[0] == 1)
                state <= 3'b010;
            else
                state <= 3'b000;
        end else begin
            state <= 3'b000;
        end
    end
end

o_fan = (i_fan_on || any(o_heater_full, o_heater_medium, o_heater_low, o_aircon_full, o_aircon_medium, o_aircon_low));

case (state)
    3'b000: // HEAT_LOW
        o_heater_low = 1;
        o_heater_full <= 0;
        o_heater_medium <= 0;
        o_heater_high <= 0;
        o_aircon_full <= 0;
        o_aircon_medium <= 0;
        o_aircon_low <= 0;
        o_fan <= 0;
    else if (3'b001) // HEAT_MED
        o_heater_medium = 1;
        o_heater_low <= 0;
        o_heater_full <= 0;
        o_aircon_full <= 0;
        o_aircon_medium <= 0;
        o_aircon_low <= 0;
        o_fan <= 0;
    else if (3'b010) // HEAT_FULL
        o_heater_full = 1;
        o_heater_medium <= 0;
        o_heater_low <= 0;
        o_aircon_full <= 0;
        o_aircon_medium <= 0;
        o_aircon_low <= 0;
        o_fan <= 0;
    else if (3'b011) // AMBIENT
        o_heater_full <= 0;
        o_heater_medium <= 0;
        o_heater_low <= 0;
        o_aircon_full <= 0;
        o_aircon_medium <= 0;
        o_aircon_low <= 0;
        o_fan <= 0;
    default: // shouldn't happen
        o_heater_full <= 0;
        o_heater_medium <= 0;
        o_heater_low <= 0;
        o_aircon_full <= 0;
        o_aircon_medium <= 0;
        o_aircon_low <= 0;
        o_fan <= 0;
endcase

endmodule
