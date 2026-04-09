module car_parking_system (
    input clk,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    output reg [1:0] available_spaces,
    output reg [1:0] count_car,
    output reg led_status,
    output seven_seg_display_available_tens[6:0],
    output seven_seg_display_available_units[6:0],
    output seven_seg_display_count_tens[6:0],
    output seven_seg_display_count_units[6:0]
);

reg current_state;

always @(posedge clk) begin
    if (reset) begin
        available_spaces <= 12;
        count_car <= 0;
        led_status <= 1'b1;
        available_spaces_tens[6:0] = 7;
        available_spaces_units[6:0] = 0;
        count_car_tens[6:0] = 0;
        count_car_units[6:0] = 0;
        current_state <= 2'b00;
    end else begin
        case (current_state)
            2'b00: begin
                if (vehicle_entry_sensor) begin
                    if (available_spaces > 0) begin
                        available_spaces <= available_spaces - 1;
                        count_car <= count_car + 1;
                        led_status <= 1'b0;
                    end
                end
                next_state = 2'b01;
            end
            2'b01: begin
                if (vehicle_exit_sensor) begin
                    available_spaces <= available_spaces + 1;
                    count_car <= count_car - 1;
                    led_status <= 1'b1;
                end
                next_state = 2'b00;
            end
            default: next_state = 2'b00;
        endcase
    end
end

always @(*) begin
    available_spaces_tens[6:0] = available_spaces / 10;
    available_spaces_units[6:0] = available_spaces % 10;
    count_car_tens = count_car / 10;
    count_car_units = count_car % 10;
end

assign led_status = available_spaces > 0;

endmodule
