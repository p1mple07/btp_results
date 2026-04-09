module car_parking_system(
    input clk,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    output reg [7:0] available_spaces,
    output reg [7:0] count_car,
    output reg led_status,
    output [6:0] seven_seg_display_available_tens,
    output [6:0] seven_seg_display_available_units,
    output [6:0] seven_seg_display_count_tens,
    output [6:0] seven_seg_display_count_units
);

    // Define the FSM states
    enum {Idle, EntryProcessing, ExitProcessing, Full} state_enum;
    reg [2:0] state, next_state;

    // FSM process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= Idle;
            available_spaces <= 12'b11111111;
            count_car <= 7'b000000;
            led_status <= 1'b1;
            seven_seg_display_available_tens <= 7'b11;
            seven_seg_display_available_units <= 7'b1;
            seven_seg_display_count_tens <= 7'b0;
            seven_seg_display_count_units <= 7'b0;
        end else begin
            state <= next_state;
        end
    end

    // State transition logic
    always @(*) begin
        case (state)
            Idle: begin
                if (vehicle_entry_sensor) begin
                    next_state <= EntryProcessing;
                    available_spaces <= 12'b11111110;
                    count_car <= 7'b000001;
                    led_status <= 1'b1;
                    seven_seg_display_available_tens <= 7'b11;
                    seven_seg_display_available_units <= 7'b1;
                    seven_seg_display_count_tens <= 7'b0;
                    seven_seg_display_count_units <= 7'b0;
                end
            end
            EntryProcessing: begin
                if (vehicle_exit_sensor) begin
                    next_state <= ExitProcessing;
                    available_spaces <= 12'b11111111;
                    count_car <= 7'b000001;
                    led_status <= 1'b1;
                    seven_seg_display_available_tens <= 7'b11;
                    seven_seg_display_available_units <= 7'b1;
                    seven_seg_display_count_tens <= 7'b0;
                    seven_seg_display_count_units <= 7'b0;
                end
            end
            ExitProcessing: begin
                next_state <= Idle;
                available_spaces <= 12'b11111111;
                count_car <= 7'b000001;
                led_status <= 1'b1;
                seven_seg_display_available_tens <= 7'b11;
                seven_seg_display_available_units <= 7'b1;
                seven_seg_display_count_tens <= 7'b0;
                seven_seg_display_count_units <= 7'b0;
            end
            Full: begin
                next_state <= Idle;
                available_spaces <= 12'b00000000;
                count_car <= 7'b000000;
                led_status <= 1'b0;
                seven_seg_display_available_tens <= 7'b0;
                seven_seg_display_available_units <= 7'b0;
                seven_seg_display_count_tens <= 7'b0;
                seven_seg_display_count_units <= 7'b0;
            end
        endcase
    end

endmodule
