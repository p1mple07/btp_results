module thermostat (
    input wire i_clk,
    input wire i_rst,
    input wire i_enable,
    input wire i_fault,
    input wire i_clr,
    input [5:0] i_temp_feedback,
    output reg o_heater_full,
    output reg o_heater_medium,
    output reg o_heater_low,
    output reg o_aircon_full,
    output reg o_aircon_medium,
    output reg o_heater_high? Wait, we don't have a high for heating? The heating outputs are full, medium, low. There's no high for heating? The design didn't mention high heating. The states are full, medium, low. So we only have those.

    output reg o_aircon_full,
    output reg o_aircon_medium,
    output reg o_aircon_low,
    output reg o_fan
);

// reset and enable logic
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
        o_aircon_full <= 0; o_aircon_medium <= 0; o_aircon_low <= 0;
        o_fan <= 0;
        // reset all outputs
    end else if (i_enable == 0) begin
        o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
        o_aircon_full <= 0; o_aircon_medium <= 0; o_aircon_low <= 0;
        o_fan <= 0;
    end else if (i_fault == 1) begin
        o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
        o_aircon_full <= 0; o_aircon_medium <= 0; o_aircon_low <= 0;
        o_fan <= 0;
    end else if (i_clr == 1) begin
        o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
        o_aircon_full <= 0; o_aircon_medium <= 0; o_aircon_low <= 0;
        o_fan <= 0;
        // after clearing, go to ambient
    end
end

always @(posedge i_clk) begin
    if (!i_rst) begin
        // idle state, default to ambient
        o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
        o_aircon_full <= 0; o_aircon_medium <= 0; o_aircon_low <= 0;
        o_fan <= 0;
    end else begin
        // evaluate temperature feedback
        // According to spec: Cold conditions priority first, then hot, then ambient.
        if (i_full_cold) begin
            o_heater_full <= 1;
            // others 0
        end else if (i_medium_cold) begin
            o_heater_medium <= 1;
            // others 0
        end else if (i_low_cold) begin
            o_heater_low <= 1;
            // others 0
        end else if (i_full_hot) begin
            o_heater_full <= 1;
            // others 0
        end else if (i_medium_hot) begin
            o_heater_medium <= 1;
            // others 0
        end else if (i_low_hot) begin
            o_heater_low <= 1;
            // others 0
        end else begin // ambient
            o_heater_full <= 0; o_heater_medium <= 0; o_heater_low <= 0;
        end

        // Cooling similar
        if (i_full_hot) begin
            o_aircon_full <= 1;
            o_aircon_medium <= 0; o_aircon_low <= 0;
        end else if (i_medium_hot) begin
            o_aircon_medium <= 1;
            // others 0
        end else if (i_low_hot) begin
            o_aircon_low <= 1;
            // others 0
        end else begin
            o_aircon_full <= 0; o_aircon_medium <= 0; o_aircon_low <= 0;
        end

        // Fan control: if any heater or aircon output active, or fan on, set to 1
        o_fan <= (o_heater_full || o_heater_medium || o_heater_low || o_aircon_full || o_aircon_medium || o_fan_on);
    end
end

endmodule
