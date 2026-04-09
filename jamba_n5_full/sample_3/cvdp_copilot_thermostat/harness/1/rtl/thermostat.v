module thermostat(
    input wire i_temp_feedback[5:0],
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_clr,
    input wire clk,
    input wire rst
);

    reg [2:0] state;           // 3‑bit state machine
    reg o_heater_full, o_heater_medium, o_heater_low, o_aircon_full, o_aircon_medium, o_aircon_low, o_fan;
    reg o_fan_control;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 3'b000;          // Reset to ambient
            o_heater_full <= 0;
            o_heater_medium <= 0;
            o_heater_low <= 0;
            o_aircon_full <= 0;
            o_aircon_medium <= 0;
            o_aircon_low <= 0;
            o_fan <= 0;
            o_fan_control <= 0;
        end else begin
            case (state)
                3'b000: begin
                    if (i_full_cold) o_heater_full <= 1;
                    else if (i_medium_cold) o_heater_medium <= 1;
                    else if (i_low_cold) o_heater_low <= 1;
                end
                3'b001: begin
                    if (i_full_hot) o_heater_full <= 1;
                    else if (i_medium_hot) o_heater_medium <= 1;
                    else if (i_low_hot) o_heater_low <= 1;
                end
                3'b010: begin
                    if (i_full_hot) o_heater_full <= 1;
                    else if (i_medium_hot) o_heater_medium <= 1;
                    else if (i_low_hot) o_heater_low <= 1;
                end
                3'b011: begin
                    o_fan <= 1;            // Ambient mode
                end
                3'b100: begin
                    if (i_full_hot) o_aircon_full <= 1;
                    else if (i_medium_hot) o_aircon_medium <= 1;
                    else if (i_low_hot) o_aircon_low <= 1;
                end
                3'b101: begin
                    if (i_full_hot) o_aircon_full <= 1;
                    else if (i_medium_hot) o_aircon_medium <= 1;
                    else if (i_low_hot) o_aircon_low <= 1;
                end
                3'b110: begin
                    if (i_full_hot) o_aircon_full <= 1;
                    else if (i_medium_hot) o_aircon_medium <= 1;
                    else if (i_low_hot) o_aircon_low <= 1;
                end
            endcase

            // Fan control logic
            o_fan <= (i_fan_on) ? 1 : 0;

            // Outputs
            o_heater_full   <= (state == 3'b000 && i_full_cold) ? 1 : 0;
            o_heater_medium  <= (state == 3'b001 && i_full_hot) ? 1 : 0;
            o_heater_low     <= (state == 3'b010 && i_full_hot) ? 1 : 0;

            o_aircon_full    <= (state == 3'b001 && i_full_hot) ? 1 : 0;
            o_aircon_medium   <= (state == 3'b011 && i_full_hot) ? 1 : 0;
            o_aircon_low      <= (state == 3'b101 && i_full_hot) ? 1 : 0;

            // Clean up if a fault occurs
            if (i_fault) o_heater_full <= 0;
            if (i_fault) o_heater_medium <= 0;
            if (i_fault) o_heater_low <= 0;
            if (i_fault) o_aircon_full <= 0;
            if (i_fault) o_aircon_medium <= 0;
            if (i_fault) o_aircon_low <= 0;

            // Clear the error state on clr
            if (i_clr) begin
                state <= 3'b000;
                o_heater_full <= 0;
                o_heater_medium <= 0;
                o_heater_low <= 0;
                o_aircon_full <= 0;
                o_aircon_medium <= 0;
                o_aircon_low <= 0;
                o_fan <= 0;
                o_fan_control <= 0;
            end

            // Handle asynchronous reset
            if (i_rst) begin
                state <= 3'b000;
                o_heater_full <= 0;
                o_heater_medium <= 0;
                o_heater_low <= 0;
                o_aircon_full <= 0;
                o_aircon_medium <= 0;
                o_aircon_low <= 0;
                o_fan <= 0;
                o_fan_control <= 0;
            end
        end
    end

endmodule
