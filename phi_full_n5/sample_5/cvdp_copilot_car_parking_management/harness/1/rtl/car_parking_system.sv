module car_parking_system(
    input clk,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    
    output reg [10:0] available_spaces,
    output reg [10:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units
);

parameter TOTAL_SPACES = 12;

reg [10:0] current_spaces, current_car_count;
reg [10:0] spaces_to_display_tens, spaces_to_display_units;
reg [6:0] count_to_display_tens, count_to_display_units;

initial current_spaces = TOTAL_SPACES;
initial current_car_count = 0;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_spaces <= TOTAL_SPACES;
        current_car_count <= 0;
        led_status <= 1;
        spaces_to_display_tens <= 12'b0000000;
        spaces_to_display_units <= 7'b000000;
        count_to_display_tens <= 7'b000000;
        count_to_display_units <= 7'b000000;
    end else begin
        if (vehicle_entry_sensor) begin
            if (current_spaces > 0) begin
                current_spaces <= current_spaces - 1;
                current_car_count <= current_car_count + 1;
            end
        end
        if (vehicle_exit_sensor) begin
            current_spaces <= current_spaces + 1;
            current_car_count <= current_car_count - 1;
        end

        led_status <= (current_spaces == 0);

        spaces_to_display_tens = current_spaces / 10;
        spaces_to_display_units = current_spaces % 10;
        count_to_display_tens = current_car_count / 10;
        count_to_display_units = current_car_count % 10;
    end
end

always @(current_spaces or current_car_count) begin
    if (current_spaces == TOTAL_SPACES) begin
        seven_seg_display_available_tens <= {spaces_to_display_tens, 7'b000000};
        seven_seg_display_available_units <= {spaces_to_display_units, 7'b000000};
        seven_seg_display_count_tens <= {count_to_display_tens, 7'b000000};
        seven_seg_display_count_units <= {count_to_display_units, 7'b000000};
    end
end

endmodule
