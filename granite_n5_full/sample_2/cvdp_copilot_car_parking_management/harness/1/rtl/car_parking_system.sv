module car_parking_system #(parameter TOTAL_SPACES=12)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    output reg [TOTAL_SPACES-1:0] available_spaces,
    output reg [TOTAL_SPACES-1:0] count_car,
    output reg led_status,
    output reg [5:0] seven_seg_display_available_tens,
    output reg [5:0] seven_seg_display_available_units,
    output reg [5:0] seven_seg_display_count_tens,
    output reg [5:0] seven_seg_display_count_units
);

always @(posedge clk) begin
    if (reset) begin
        available_spaces <= TOTAL_SPACES;
        count_car <= 0;
        led_status <= 1'b0;
        seven_seg_display_available_tens <= 6'b0;
        seven_seg_display_available_units <= 6'b0;
        seven_seg_display_count_tens <= 6'b0;
        seven_seg_display_count_units <= 6'b0;
    end else begin
        if (vehicle_entry_sensor && available_spaces > 0) begin
            available_spaces <= available_spaces - 1;
            count_car <= count_car + 1;
            led_status <= 1'b0;
        end else if (!vehicle_entry_sensor && count_car > 0) begin
            available_spaces <= available_spaces + 1;
            count_car <= count_car - 1;
            led_status <= 1'b1;
        end
    end
end

// 7-segment decoder logic goes here...

endmodule