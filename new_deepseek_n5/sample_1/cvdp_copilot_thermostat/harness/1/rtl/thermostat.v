module thermostat(
    input wire [5:0] i_temp_feedback,
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_rst,
    output reg [2:0] o_state,
    output reg [1:0] o_heater_full, o_heater_medium, o_heater_low,
    output reg [1:0] o_aircon_full, o_aircon_medium, o_aircon_low,
    output reg o_fan
);

    reg current_state = 3'b000; // AMBIENT

    always @posedge i_rst) begin
        o_state = 3'b000;
        o_heater_full = 0;
        o_heater_medium = 0;
        o_heater_low = 0;
        o_aircon_full = 0;
        o_aircon_medium = 0;
        o_aircon_low = 0;
        o_fan = 0;
    end

    always @posedge i_rst or @* i_fault or @* i_enable) begin
        if (i_fault) begin
            o_state = 3'b000;
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
            o_fan = 0;
        else if (i_enable) begin
            o_heater_full = 0;
            o_heater_medium = 0;
            o_heater_low = 0;
            o_aircon_full = 0;
            o_aircon_medium = 0;
            o_aircon_low = 0;
        else if (o_state == 3'b000) begin // AMBIENT
            if (i_temp_feedback[5] == 1) begin
                o_state = 3'b011;
                o_heater_full = 1;
            else if (i_temp_feedback[4] == 1) begin
                o_state = 3'b010;
                o_heater_medium = 1;
            else if (i_temp_feedback[3] == 1) begin
                o_state = 3'b001;
                o_heater_low = 1;
            else if (i_temp_feedback[2] == 1) begin
                o_state = 3'b110;
                o_aircon_low = 1;
            else if (i_temp_feedback[1] == 1) begin
                o_state = 3'b101;
                o_aircon_medium = 1;
            else if (i_temp_feedback[0] == 1) begin
                o_state = 3'b111;
                o_aircon_full = 1;
            end
        else if (o_state == 3'b011) begin // HEAT_FULL
            if (i_temp_feedback[5] == 1) begin
                o_state = 3'b011;
            else if (i_temp_feedback[4] == 1) begin
                o_state = 3'b010;
                o_heater_medium = 1;
            else if (i_temp_feedback[3] == 1) begin
                o_state = 3'b001;
                o_heater_low = 1;
            else begin
                o_state = 3'b110;
                o_aircon_low = 1;
            end
        else if (o_state == 3'b010) begin // HEAT MED
            if (i_temp_feedback[5] == 1) begin
                o_state = 3'b010;
            else if (i_temp_feedback[4] == 1) begin
                o_state = 3'b001;
                o_heater_low = 1;
            else begin
                o_state = 3'b110;
                o_aircon_low = 1;
            end
        else if (o_state == 3'b001) begin // HEAT_LOW
            if (i_temp_feedback[5] == 1) begin
                o_state = 3'b001;
            else begin
                o_state = 3'b110;
                o_aircon_low = 1;
            end
        else if (o_state == 3'b110) begin // COOL_LOW
            if (i_temp_feedback[2] == 1) begin
                o_state = 3'b110;
            else if (i_temp_feedback[1] == 1) begin
                o_state = 3'b101;
                o_aircon_medium = 1;
            else if (i_temp_feedback[0] == 1) begin
                o_state = 3'b111;
                o_aircon_full = 1;
            else begin
                o_state = 3'b000;
            end
        else if (o_state == 3'b101) begin // COOL_MED
            if (i_temp_feedback[2] == 1) begin
                o_state = 3'b101;
            else if (i_temp_feedback[1] == 1) begin
                o_state = 3'b100;
                o_aircon_high = 1;
            else if (i_temp_feedback[0] == 1) begin
                o_state = 3'b000;
            else begin
                o_state = 3'b000;
            end
        else if (o_state == 3'b100) begin // COOL_FULL
            if (i_temp_feedback[2] == 1) begin
                o_state = 3'b100;
            else begin
                o_state = 3'b000;
            end
        else begin
            o_state = 3'b000;
        end
    end

    // Fan control
    o_fan = i_fan_on || (o_heater_full || o_heater_medium || o_heater_low || o_aircon_full || o_aircon_medium || o_aircon_low);

endmodule