module thermostat(
    input [5:0] i_temp_feedback,
    input i_fan_on,
    input i_enable,
    input i_fault,
    input i_clr,
    input i_clk,
    input i_rst,
    output reg o_heater_full,
    output reg o_heater_medium,
    output reg o_heater_low,
    output reg o_aircon_full,
    output reg o_aircon_medium,
    output reg o_aircon_low,
    output reg o_fan,
    output reg [2:0] o_state
);

    // FSM state register
    reg [2:0] fsm_state = 3'b000; // Default state: AMBIENT

    // Asynchronous reset
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst)
            fsm_state <= 3'b000;
    end

    // Fault state logic
    always @(i_fault or i_clr or i_enable) begin
        if (i_fault)
            fsm_state <= 3'b000;
        else if (i_clr)
            fsm_state <= 3'b000;
        else if (i_enable == 0)
            fsm_state <= 3'b000;
    end

    // FSM state transition logic
    always @(posedge i_clk) begin
        case (fsm_state)
            3'b000: // AMBIENT
                if (i_temp_feedback[5])
                    fsm_state = 3'b100; // COOL_LOW
                else if (i_temp_feedback[4])
                    fsm_state = 3'b101; // COOL_MED
                else if (i_temp_feedback[3])
                    fsm_state = 3'b110; // COOL_FULL
                else
                    fsm_state = 3'b000;

            3'b100: // COOL_LOW
                if (i_temp_feedback[2])
                    fsm_state = 3'b010; // HEAT_LOW
                else if (i_temp_feedback[1])
                    fsm_state = 3'b011; // HEAT_MED
                else if (i_temp_feedback[0])
                    fsm_state = 3'b000; // AMBIENT

            3'b101: // COOL_MED
                if (i_temp_feedback[5])
                    fsm_state = 3'b010; // HEAT_LOW
                else if (i_temp_feedback[4])
                    fsm_state = 3'b011; // HEAT_MED
                else if (i_temp_feedback[3])
                    fsm_state = 3'b110; // COOL_FULL
                else
                    fsm_state = 3'b000;

            3'b110: // COOL_FULL
                if (i_temp_feedback[5])
                    fsm_state = 3'b000; // AMBIENT
                else if (i_temp_feedback[4])
                    fsm_state = 3'b010; // HEAT_LOW
                else if (i_temp_feedback[3])
                    fsm_state = 3'b011; // HEAT_MED
                else
                    fsm_state = 3'b100; // COOL_LOW

            3'b000: // AMBIENT
                // No transitions needed, FSM remains in AMBIENT
        endcase
    end

    // Output logic
    always @(*) begin
        case (fsm_state)
            3'b000:
                o_heater_full = 0;
                o_heater_medium = 0;
                o_heater_low = 0;
                o_aircon_full = 0;
                o_aircon_medium = 0;
                o_aircon_low = 0;
                o_fan = i_fan_on;
                o_state = 3'b000;

            3'b100:
                o_heater_full = 0;
                o_heater_medium = 0;
                o_heater_low = 1;
                o_aircon_full = 1;
                o_aircon_medium = 0;
                o_aircon_low = 0;
                o_fan = i_fan_on;
                o_state = 3'b100;

            3'b101:
                o_heater_full = 0;
                o_heater_medium = 1;
                o_heater_low = 0;
                o_aircon_full = 0;
                o_aircon_medium = 1;
                o_aircon_low = 0;
                o_fan = i_fan_on;
                o_state = 3'b101;

            3'b110:
                o_heater_full = 0;
                o_heater_medium = 0;
                o_heater_low = 1;
                o_aircon_full = 0;
                o_aircon_medium = 0;
                o_aircon_low = 1;
                o_fan = i_fan_on;
                o_state = 3'b110;

            default:
                o_heater_full = 0;
                o_heater_medium = 0;
                o_heater_low = 0;
                o_aircon_full = 0;
                o_aircon_medium = 0;
                o_aircon_low = 0;
                o_fan = i_fan_on;
                o_state = 3'b000;
        endcase
    end
endmodule
