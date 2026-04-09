module thermostat(
    input wire [5:0] i_temp_feedback,
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_rst,
    output reg [2:0] o_state,
    output reg [5:0] o_heater_full,
    output reg [5:0] o_heater_medium,
    output reg [5:0] o_heater_low,
    output reg [5:0] o_aircon_full,
    output reg [5:0] o_aircon_medium,
    output reg [5:0] o_aircon_low,
    output reg o_fan
);

    reg [2:0] state = 000;
    reg next_state = 000;

    always @posedge i_clk begin
        if (i_rst) begin
            state = 000;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = 0;
            next_state = 000;
        elsif (i_fault) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = 0;
            next_state = 000;
        elsif (i_enable) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = 0;
            next_state = state;
        else begin
            case (state)
                3'b000: // AMBIENT
                    if (i_temp_feedback[5]) begin
                        next_state = 3'b011;
                        o_heater_full = 1;
                    end else if (i_temp_feedback[4]) begin
                        next_state = 3'b010;
                        o_heater_medium = 1;
                    end else if (i_temp_feedback[3]) begin
                        next_state = 3'b001;
                        o_heater_low = 1;
                    end else if (i_temp_feedback[2]) begin
                        next_state = 3'b100;
                        o_aircon_low = 1;
                    end else if (i_temp_feedback[1]) begin
                        next_state = 3'b101;
                        o_aircon_medium = 1;
                    end else if (i_temp_feedback[0]) begin
                        next_state = 3'b110;
                        o_aircon_full = 1;
                    end else begin
                        next_state = state;
                    end
                3'b001: // HEAT MED
                    if (i_temp_feedback[5]) begin
                        next_state = 3'b011;
                        o_heater_full = 1;
                    end else if (i_temp_feedback[4]) begin
                        next_state = 3'b010;
                        o_heater_medium = 1;
                    end else if (i_temp_feedback[3]) begin
                        next_state = 3'b001;
                        o_heater_low = 1;
                    end else if (i_temp_feedback[2]) begin
                        next_state = 3'b100;
                        o_aircon_low = 1;
                    end else if (i_temp_feedback[1]) begin
                        next_state = 3'b101;
                        o_aircon_medium = 1;
                    end else if (i_temp_feedback[0]) begin
                        next_state = 3'b110;
                        o_aircon_full = 1;
                    end else begin
                        next_state = state;
                    end
                3'b010: // HEAT LOW
                    if (i_temp_feedback[5]) begin
                        next_state = 3'b011;
                        o_heater_full = 1;
                    end else if (i_temp_feedback[4]) begin
                        next_state = 3'b010;
                        o_heater_medium = 1;
                    end else if (i_temp_feedback[3]) begin
                        next_state = 3'b001;
                        o_heater_low = 1;
                    end else if (i_temp_feedback[2]) begin
                        next_state = 3'b100;
                        o_aircon_low = 1;
                    end else if (i_temp_feedback[1]) begin
                        next_state = 3'b101;
                        o_aircon_medium = 1;
                    end else if (i_temp_feedback[0]) begin
                        next_state = 3'b110;
                        o_aircon_full = 1;
                    end else begin
                        next_state = state;
                    end
                3'b011: // AMBIENT
                    next_state = state;
                3'b100: // COOL LOW
                    if (i_temp_feedback[5]) begin
                        next_state = 3'b100;
                        o_aircon_low = 1;
                    end else if (i_temp_feedback[4]) begin
                        next_state = 3'b101;
                        o_aircon_medium = 1;
                    end else if (i_temp_feedback[3]) begin
                        next_state = 3'b110;
                        o_aircon_full = 1;
                    end else if (i_temp_feedback[2]) begin
                        next_state = 3'b000;
                        o_heater_low = 1;
                    end else if (i_temp_feedback[1]) begin
                        next_state = 3'b001;
                        o_heater_medium = 1;
                    end else if (i_temp_feedback[0]) begin
                        next_state = 3'b010;
                        o_heater_full = 1;
                    end else begin
                        next_state = state;
                    end
                3'b101: // COOL MED
                    if (i_temp_feedback[5]) begin
                        next_state = 3'b100;
                        o_aircon_low = 1;
                    end else if (i_temp_feedback[4]) begin
                        next_state = 3'b101;
                        o_aircon_medium = 1;
                    end else if (i_temp_feedback[3]) begin
                        next_state = 3'b110;
                        o_aircon_full = 1;
                    end else if (i_temp_feedback[2]) begin
                        next_state = 3'b000;
                        o_heater_low = 1;
                    end else if (i_temp_feedback[1]) begin
                        next_state = 3'b001;
                        o_heater_medium = 1;
                    end else if (i_temp_feedback[0]) begin
                        next_state = 3'b010;
                        o_heater_full = 1;
                    end else begin
                        next_state = state;
                    end
                3'b110: // COOL FULL
                    if (i_temp_feedback[5]) begin
                        next_state = 3'b100;
                        o_aircon_low = 1;
                    end else if (i_temp_feedback[4]) begin
                        next_state = 3'b101;
                        o_aircon_medium = 1;
                    end else if (i_temp_feedback[3]) begin
                        next_state = 3'b110;
                        o_aircon_full = 1;
                    end else begin
                        next_state = state;
                    end
                default:
                    next_state = state;
            end case
        endif
    endalways

    // Assign outputs based on state
    o_heater_full = (state == 3'b011) ? 1 : 0;
    o_heater_medium = (state == 3'b010) ? 1 : 0;
    o_heater_low = (state == 3'b001) ? 1 : 0;
    o_aircon_full = (state == 3'b110) ? 1 : 0;
    o_aircon_medium = (state == 3'b101) ? 1 : 0;
    o_aircon_low = (state == 3'b000) ? 1 : 0;
    o_fan = (state == 3'b011 || state == 3'b010 || state == 3'b001 || state == 3'b110 || state == 3'b101 || state == 3'b000) ? 
        (i_fan_on || o_heater_full || o_heater_medium || o_heater_low || o_aircon_full || o_aircon_medium || o_aircon_low) ? 1 : 0 : 0;
    
    // Ensure o_fan is 0 when all outputs are 0
    o_fan = 0;
    next_state = state;
endmodule