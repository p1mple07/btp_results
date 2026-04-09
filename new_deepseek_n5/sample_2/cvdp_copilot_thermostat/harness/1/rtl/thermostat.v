module thermostat(
    input wire [5:0] i_temp_feedback,
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_rst,
    output wire [2:0] o_state,
    output wire o_heater_full,
    output wire o_heater_medium,
    output wire o_heater_low,
    output wire o_aircon_full,
    output wire o_aircon_medium,
    output wire o_aircon_low,
    output wire o_fan
);

    // Reset override
    if (i_rst) begin
        o_state = 3'b000;
        o_heater_full = 0;
        o_heater_medium = 0;
        o_heater_low = 0;
        o_aircon_full = 0;
        o_aircon_medium = 0;
        o_aircon_low = 0;
        o_fan = 0;
        return;
    end

    // Fault override
    if (i_fault) begin
        o_state = 3'b000;
        o_heater_full = 0;
        o_heater_medium = 0;
        o_heater_low = 0;
        o_aircon_full = 0;
        o_aircon_medium = 0;
        o_aircon_low = 0;
        o_fan = 0;
        return;
    end

    // Enable override
    if (i_enable) begin
        o_state = o_state; // FSM state remains same
        o_heater_full = 0;
        o_heater_medium = 0;
        o_heater_low = 0;
        o_aircon_full = 0;
        o_aircon_medium = 0;
        o_aircon_low = 0;
    end

    // Default state transitions
    case (i_temp_feedback)
        6'b111000: // full hot
            o_state = 3'b110;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = i_fan_on || (o_state == 3'b110);
            break;
        6'b110100: // medium hot
            o_state = 3'b101;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = i_fan_on || (o_state == 3'b101);
            break;
        6'b101000: // low hot
            o_state = 3'b100;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = i_fan_on || (o_state == 3'b100);
            break;
        6'b011000: // full cold
            o_state = 3'b001;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = i_fan_on || (o_state == 3'b001);
            break;
        6'b010100: // medium cold
            o_state = 3'b010;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = i_fan_on || (o_state == 3'b010);
            break;
        6'b001000: // low cold
            o_state = 3'b011;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = i_fan_on || (o_state == 3'b011);
            break;
        default:
            o_state = 3'b000;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = i_fan_on || (o_state == 3'b000);
            break;
    endcase

    // Generate outputs based on state
    generate
        if (o_state == 3'b000) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
        else if (o_state == 3'b001) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 1;
        end else if (o_state == 3'b010) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 1;
            o_aircon_low = 0;
        end else if (o_state == 3'b011) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 1;
            o_aircon_low = 1;
        end else if (o_state == 3'b100) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 1;
            o_aircon_medium = 0;
            o_aircon_low = 0;
        end else if (o_state == 3'b101) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 1;
            o_aircon_medium = 1;
            o_aircon_low = 0;
        end else if (o_state == 3'b110) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 1;
            o_aircon_medium = 0;
            o_aircon_low = 1;
        end
    endgenerate

endmodule