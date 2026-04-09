module car_parking_system(
    input clk,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    output reg [7:0] available_spaces,
    output reg [7:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units
);

parameter TOTAL_SPACES = 12;

reg [TOTAL_SPACES-1:0] current_spaces, current_cars;
reg [TOTAL_SPACES-1:0] available_spaces_reg, count_cars_reg;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_spaces <= TOTAL_SPACES;
        current_cars <= 0;
        available_spaces_reg <= TOTAL_SPACES;
        count_cars_reg <= 0;
        led_status <= 1;
        seven_seg_display_available_tens <= 7;
        seven_seg_display_available_units <= 2;
        seven_seg_display_count_tens <= 0;
        seven_seg_display_count_units <= 0;
    end else begin
        if (reset) begin
            current_spaces <= TOTAL_SPACES;
            current_cars <= 0;
            available_spaces_reg <= TOTAL_SPACES;
            count_cars_reg <= 0;
            led_status <= 1;
            seven_seg_display_available_tens <= 7;
            seven_seg_display_available_units <= 2;
            seven_seg_display_count_tens <= 0;
            seven_seg_display_count_units <= 0;
        end else if (vehicle_entry_sensor) begin
            current_spaces <= current_spaces - 1;
            current_cars <= current_cars + 1;
            available_spaces_reg <= current_spaces;
            count_cars_reg <= current_cars;
            led_status <= 1;
            seven_seg_display_available_tens <= (current_spaces % 10);
            seven_seg_display_available_units <= (current_spaces / 10);
            seven_seg_display_count_tens <= current_cars % 10;
            seven_seg_display_count_units <= current_cars / 10;
        end else if (vehicle_exit_sensor) begin
            current_spaces <= current_spaces + 1;
            current_cars <= current_cars - 1;
            available_spaces_reg <= current_spaces;
            count_cars_reg <= current_cars;
            led_status <= 1;
            seven_seg_display_available_tens <= (current_spaces % 10);
            seven_seg_display_available_units <= (current_spaces / 10);
            seven_seg_display_count_tens <= current_cars % 10;
            seven_seg_display_count_units <= current_cars / 10;
        end
    end
end

always @(posedge clk) begin
    if (current_spaces == 0)
        led_status <= 0;
    else
        led_status <= 1;
end

always @(posedge clk) begin
    if (available_spaces_reg == 0)
        seven_seg_display_available_tens <= 0;
    else
        seven_seg_display_available_tens <= (available_spaces_reg % 10);
end

always @(posedge clk) begin
    if (count_cars_reg == TOTAL_SPACES)
        seven_seg_display_count_tens <= 0;
    else
        seven_seg_display_count_tens <= count_cars_reg % 10;
end

always @(posedge clk) begin
    if (count_cars_reg == 0)
        seven_seg_display_count_units <= 0;
    else
        seven_seg_display_count_units <= count_cars_reg / 10;
end

endmodule
