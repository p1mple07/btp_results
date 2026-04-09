module car_parking_system(
    input clk,
    input reset,
    input vehicle_entry_sensor,
    input vehicle_exit_sensor,
    output reg [11:0] available_spaces,
    output reg [11:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units
);

    parameter TOTAL_SPACES = 12;
    reg [TOTAL_SPACES-1:0] spaces_count = TOTAL_SPACES;
    reg [TOTAL_SPACES-1:0] car_count = 0;

    // FSM states
    localparam [3:0] Idle = 4'b0000,
                  EntryProcessing = 4'b0001,
                  ExitProcessing = 4'b0010,
                  Full = 4'b0100;

    reg [3:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= Idle;
            spaces_count <= TOTAL_SPACES;
            car_count <= 0;
            led_status <= 1'b1;
            seven_seg_display_available_tens <= TOTAL_SPACES - 1;
            seven_seg_display_available_units <= 1'b1;
            seven_seg_display_count_tens <= 0;
            seven_seg_display_count_units <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    always @(current_state or vehicle_entry_sensor or vehicle_exit_sensor) begin
        case (current_state)
            Idle: begin
                if (vehicle_entry_sensor) begin
                    next_state <= EntryProcessing;
                    available_spaces <= spaces_count - 1;
                    car_count <= car_count + 1;
                    led_status <= 1'b1;
                    seven_seg_display_available_tens <= available_spaces - 1;
                    seven_seg_display_available_units <= car_count;
                end
                else next_state <= Idle;
            end
            EntryProcessing: begin
                if (vehicle_exit_sensor) begin
                    next_state <= ExitProcessing;
                    spaces_count <= spaces_count + 1;
                    car_count <= car_count - 1;
                    led_status <= 1'b1;
                    seven_seg_display_available_tens <= spaces_count - 1;
                    seven_seg_display_available_units <= car_count;
                end
                else next_state <= EntryProcessing;
            end
            ExitProcessing: begin
                next_state <= Idle;
                available_spaces <= spaces_count + 1;
                car_count <= car_count + 1;
                led_status <= 1'b0;
                seven_seg_display_available_tens <= spaces_count - 1;
                seven_seg_display_available_units <= car_count;
            end
            Full: begin
                next_state <= Idle;
                available_spaces <= 0;
                car_count <= 0;
                led_status <= 1'b0;
                seven_seg_display_available_tens <= 0;
                seven_seg_display_available_units <= 0;
            end
            default: next_state <= Idle;
        endcase
    end

    // Conversion from binary to 7-segment display format
    always @(*) begin
        if (led_status == 1'b1) begin
            seven_seg_display_available_tens <= spaces_count - 1;
            seven_seg_display_available_units <= car_count;
        end else begin
            seven_seg_display_available_tens <= 0;
            seven_seg_display_available_units <= 0;
        end

        // Conversion for units digit
        seven_seg_display_count_tens <= car_count / 10;
        seven_seg_display_count_units <= car_count % 10;
    end

endmodule
