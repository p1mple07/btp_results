module car_parking_system (
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    output reg available_spaces,
    output reg count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units
);

reg state; // Idle, Entry, Exit, Full
wire current_available_spaces;
wire current_count_car;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        available_spaces <= 12;
        count_car <= 0;
        led_status <= 1'b1;
        seven_seg_display_available_tens <= "1";
        seven_seg_display_available_units <= "2";
        seven_seg_display_count_tens <= "0";
        seven_seg_display_count_units <= "0";
        state <= Idle;
    end else begin
        case (state)
            Idle: begin
                if (vehicle_entry_sensor) begin
                    available_spaces <= total_spaces - 1;
                    count_car <= count_car + 1;
                    led_status <= 1'b0;
                end
                state <= Entry;
            end
            Entry: begin
                if (vehicle_entry_sensor) begin
                    available_spaces <= available_spaces - 1;
                    count_car <= count_car + 1;
                    led_status <= 1'b1;
                end
                state <= Exit;
            end
            Exit: begin
                if (vehicle_exit_sensor) begin
                    available_spaces <= available_spaces + 1;
                    count_car <= count_car - 1;
                    led_status <= 1'b0;
                end
                state <= Full;
            end
            Full: begin
                if (vehicle_entry_sensor) begin
                    available_spaces <= 12;
                    count_car <= 0;
                    led_status <= 1'b1;
                end
                state <= Idle;
            end
        endcase
    end
end

always @(posedge clk) begin
    if (state == Idle) begin
        current_available_spaces = available_spaces;
        current_count_car = count_car;
    end
    if (state == Entry) begin
        current_available_spaces = available_spaces - 1;
        current_count_car = count_car + 1;
    end
    if (state == Exit) begin
        current_available_spaces = available_spaces + 1;
        current_count_car = count_car - 1;
    end
    if (state == Full) begin
        current_available_spaces = 12;
        current_count_car = 0;
    end
end

assign available_spaces = current_available_spaces;
assign count_car = current_count_car;

always @(posedge clk) begin
    if (led_status) begin
        seven_seg_display_available_tens <= (available_spaces < 8) ? "0" + "{0}" : "1" + "{0}";
        seven_seg_display_available_units <= (available_spaces < 8) ? "0" + "{0}" : "1" + "{0}";
    end else begin
        seven_seg_display_available_tens <= "0";
        seven_seg_display_available_units <= "0";
    end
end

always @(posedge clk) begin
    if (count_car) begin
        seven_seg_display_count_tens <= (count_car < 8) ? "0" + "{0}" : "1" + "{0}";
        seven_seg_display_count_units <= (count_car < 8) ? "0" + "{0}" : "1" + "{0}";
    end else begin
        seven_seg_display_count_tens <= "0";
        seven_seg_display_count_units <= "0";
    end
end

endmodule
