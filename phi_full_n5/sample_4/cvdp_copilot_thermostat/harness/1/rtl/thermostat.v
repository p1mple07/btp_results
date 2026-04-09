module thermostat(
    input wire [5:0] i_temp_feedback,
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_clr,
    input wire i_clk,
    input wire i_rst,
    output reg [1:0] o_state,
    output reg o_heater_full,
    output reg o_heater_medium,
    output reg o_heater_low,
    output reg o_aircon_full,
    output reg o_aircon_medium,
    output reg o_aircon_low,
    output reg o_fan
);

    // Reset and enable logic
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst)
            o_state <= 3'b000;
        else if (i_enable == 0)
            o_heater_full <= 0;
            o_heater_medium <= 0;
            o_heater_low <= 0;
            o_aircon_full <= 0;
            o_aircon_medium <= 0;
            o_aircon_low <= 0;
            o_fan <= 0;
        else
            // State transition logic
            case(o_state)
                3'b000: o_state <= i_full_cold ? 3'b100 : o_state;
                3'b001: o_state <= i_medium_cold ? 3'b100 : o_state;
                3'b010: o_state <= i_low_cold ? 3'b100 : o_state;
                3'b011: o_state <= 3'b000;
                3'b100: o_state <= i_full_hot ? 3'b010 : o_state;
                3'b101: o_state <= i_medium_hot ? 3'b010 : o_state;
                3'b110: o_state <= i_low_hot ? 3'b010 : o_state;
                default: o_state <= 3'b000;
            endcase
    end

    // Fault and clr logic
    always @(posedge i_clk or posedge i_rst) begin
        if (i_fault)
            o_heater_full <= 0;
            o_heater_medium <= 0;
            o_heater_low <= 0;
            o_aircon_full <= 0;
            o_aircon_medium <= 0;
            o_aircon_low <= 0;
            o_fan <= 0;
        else if (i_clr)
            o_state <= 3'b000;
        else
            // Normal output logic
            case(o_state)
                3'b000: o_heater_full <= 1; o_heater_medium <= 0; o_heater_low <= 0;
                3'b001: o_heater_full <= 0; o_heater_medium <= 1; o_heater_low <= 0;
                3'b010: o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 1;
                3'b100: o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
                3'b101: o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
                3'b110: o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
                default: o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
            endcase
    end

    // Fan logic
    always @(posedge i_clk or posedge i_rst) begin
        if (i_fan_on)
            o_fan <= 1;
        else
            o_fan <= 0;
    end

endmodule
