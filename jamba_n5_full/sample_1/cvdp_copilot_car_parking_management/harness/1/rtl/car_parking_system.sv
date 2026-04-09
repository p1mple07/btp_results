module car_parking_system (
    input clk,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    output reg available_spaces,
    output reg count_car,
    output reg led_status,
    output reg[6:0] seven_seg_display_available_tens,
    output reg[6:0] seven_seg_display_available_units,
    output reg[6:0] seven_seg_display_count_tens,
    output reg[6:0] seven_seg_display_count_units
);

reg [3:0] state; // Idle, Entry, Exit, Full

always @(posedge clk or posedge reset) begin
    if (reset) begin
        available_spaces = 12;
        count_car = 0;
        led_status = 1'b1;
        seven_seg_display_available_tens = 1;
        seven_seg_display_available_units = 1;
        seven_seg_display_count_tens = 0;
        seven_seg_display_count_units = 0;
    end else begin
        case (state)
            state_idle: begin
                if (vehicle_entry_sensor) begin
                    state <= state_entry;
                end
            end
            state_entry: begin
                if (vehicle_entry_sensor) begin
                    available_spaces = available_spaces - 1;
                    count_car = count_car + 1;
                end
                state <= state_exit;
            end
            state_exit: begin
                if (vehicle_exit_sensor) begin
                    available_spaces = available_spaces + 1;
                    count_car = count_car - 1;
                end
                state <= state_idle;
            end
            state_full: begin
                available_spaces = 0;
                count_car = 0;
                led_status = 1'b0;
                seven_seg_display_available_tens = 0;
                seven_seg_display_available_units = 0;
                seven_seg_display_count_tens = 0;
                seven_seg_display_count_units = 0;
                state <= state_idle;
            end
        endcase
    end
end

endmodule
