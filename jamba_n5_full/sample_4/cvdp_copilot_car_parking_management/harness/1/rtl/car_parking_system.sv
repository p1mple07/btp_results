module car_parking_system(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    output reg available_spaces,
    output reg count_car,
    output reg led_status,
    output reg[6:0] seven_seg_display_available_tens,
    output reg[6:0] seven_seg_display_available_units,
    output reg[6:0] seven_seg_display_count_tens,
    output reg[6:0] seven_seg_display_count_units
);

parameter integer TOTAL_SPACES = 12;

reg [3:0] next_state;
reg current_state;
reg [3:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        available_spaces <= TOTAL_SPACES;
        count_car <= 0;
        led_status <= 1'b1;
        seven_seg_display_available_tens <= 1;
        seven_seg_display_available_units <= 2;
        seven_seg_display_count_tens <= 0;
        seven_seg_display_count_units <= 0;
        current_state <= Idle;
    end else begin
        case(current_state)
            Idle: begin
                if (vehicle_entry_sensor) begin
                    available_spaces <= TOTAL_SPACES - 1;
                    count_car <= 1;
                    led_status <= 1'b0;
                    seven_seg_display_available_tens <= 1;
                    seven_seg_display_available_units <= 2;
                    seven_seg_display_count_tens <= 0;
                    seven_seg_display_count_units <= 0;
                    next_state <= EntryProcessing;
                end
                // other conditions omitted for brevity
            end
            EntryProcessing: begin
                if (vehicle_entry_sensor && available_spaces > 0) begin
                    available_spaces <= available_spaces - 1;
                    count_car <= count_car + 1;
                    led_status <= 1'b1;
                    seven_seg_display_available_tens <= (available_spaces / 10) ? 1 : 0;
                    seven_seg_display_available_units <= (available_spaces % 10) ? 1 : 0;
                    seven_seg_display_count_tens <= (count_car / 10) ? 1 : 0;
                    seven_seg_display_count_units <= (count_car % 10) ? 1 : 0;
                    next_state <= ExitProcessing;
                end else begin
                    next_state <= Idle;
                end
            end
            ExitProcessing: begin
                if (vehicle_exit_sensor) begin
                    available_spaces <= available_spaces + 1;
                    count_car <= count_car - 1;
                    led_status <= 1'b0;
                    seven_seg_display_available_tens <= (available_spaces / 10) ? 1 : 0;
                    seven_seg_display_available_units <= (available_spaces % 10) ? 1 : 0;
                    seven_seg_display_count_tens <= (count_car / 10) ? 1 : 0;
                    seven_seg_display_count_units <= (count_car % 10) ? 1 : 0;
                    next_state <= Idle;
                end
            end
            Full: begin
                available_spaces <= 0;
                count_car <= 0;
                led_status <= 1'b0;
                seven_seg_display_available_tens <= 0;
                seven_seg_display_available_units <= 0;
                seven_seg_display_count_tens <= 0;
                seven_seg_display_count_units <= 0;
                next_state <= Idle;
            end
        endcase
    end
end

endmodule
