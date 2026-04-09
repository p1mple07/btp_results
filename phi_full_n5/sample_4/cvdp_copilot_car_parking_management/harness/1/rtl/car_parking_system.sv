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
    parameter MSB_SEGMENT = 7;
    parameter LSB_SEGMENT = 0;

    // State register
    reg [2:0] state, next_state;

    // FSM state encoding
    localparam Idle = 3'b000, EntryProcessing = 3'b001, ExitProcessing = 3'b010, Full = 3'b100;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= Idle;
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            led_status <= 1'b1;
            seven_seg_display_available_tens <= TOTAL_SPACES / 10;
            seven_seg_display_available_units <= (TOTAL_SPACES % 10);
            seven_seg_display_count_tens <= 0;
            seven_seg_display_count_units <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            Idle: begin
                if (vehicle_entry_sensor) begin
                    next_state <= EntryProcessing;
                    available_spaces <= available_spaces - 1;
                    count_car <= count_car + 1;
                    led_status <= 1'b1;
                    seven_seg_display_available_tens <= (available_spaces / 10) & TOTAL_SPACES;
                    seven_seg_display_available_units <= (available_spaces % 10);
                    seven_seg_display_count_tens <= count_car / 10;
                    seven_seg_display_count_units <= count_car % 10;
                end
            end
            EntryProcessing: begin
                if (vehicle_exit_sensor) begin
                    next_state <= ExitProcessing;
                    available_spaces <= available_spaces + 1;
                    count_car <= count_car - 1;
                    led_status <= 1'b1;
                    seven_seg_display_available_tens <= (available_spaces / 10) & TOTAL_SPACES;
                    seven_seg_display_available_units <= (available_spaces % 10);
                    seven_seg_display_count_tens <= count_car / 10;
                    seven_seg_display_count_units <= count_car % 10;
                end
            end
            ExitProcessing: begin
                if (available_spaces == TOTAL_SPACES) begin
                    next_state <= Full;
                    led_status <= 1'b0;
                    seven_seg_display_available_tens <= 0;
                    seven_seg_display_available_units <= 0;
                    seven_seg_display_count_tens <= count_car / 10;
                    seven_seg_display_count_units <= count_car % 10;
                end else begin
                    next_state <= Idle;
                end
            end
            Full: begin
                if (vehicle_entry_sensor) begin
                    next_state <= EntryProcessing;
                    available_spaces <= TOTAL_SPACES;
                    count_car <= count_car + 1;
                    led_status <= 1'b0;
                    seven_seg_display_available_tens <= TOTAL_SPACES / 10;
                    seven_seg_display_available_units <= (TOTAL_SPACES % 10);
                    seven_seg_display_count_tens <= count_car / 10;
                    seven_seg_display_count_units <= count_car % 10;
                end
            end
            default: next_state <= Idle;
        end
    end

    // LED and 7-segment display enable logic
    assign led_status = (available_spaces > 0) ? 1'b1 : 1'b0;
    assign seven_seg_display_available_tens = {MSB_SEGMENT'b1, available_spaces / 10};
    assign seven_seg_display_available_units = {LSB_SEGMENT'b1, available_spaces % 10};
    assign seven_seg_display_count_tens = {MSB_SEGMENT'b1, count_car / 10};
    assign seven_seg_display_count_units = {LSB_SEGMENT'b1, count_car % 10};

endmodule
