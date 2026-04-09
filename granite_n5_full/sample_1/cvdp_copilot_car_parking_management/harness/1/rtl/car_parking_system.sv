module car_parking_system #(parameter TOTAL_SPACES = 12) (
    input logic clk,
    input logic reset,
    input logic vehicle_entry_sensor,
    input logic vehicle_exit_sensor,
    output logic [TOTAL_SPACES-1:0] available_spaces,
    output logic [TOTAL_SPACES-1:0] count_car,
    output logic led_status,
    output logic [5:0] seven_seg_display_available_tens,
    output logic [5:0] seven_seg_display_available_units,
    output logic [5:0] seven_seg_display_count_tens,
    output logic [5:0] seven_seg_display_count_units
);

// Define the states of the FSM
typedef enum {IDLE, ENTRY_PROCESSING, EXIT_PROCESSING, FULL} state_type;
state_type curr_state, next_state;

// Implement the FSM logic
always_ff @(posedge clk) begin
    if (reset) begin
        curr_state <= IDLE;
        available_spaces <= TOTAL_SPACES;
        count_car <= 0;
        led_status <= 0;
        seven_seg_display_available_tens <= 6'd0;
        seven_seg_display_available_units <= 6'd0;
        seven_seg_display_count_tens <= 6'd0;
        seven_seg_display_count_units <= 6'd0;
    end else begin
        next_state <= curr_state;

        case (curr_state)
            IDLE: begin
                if (vehicle_entry_sensor == 1'b1) begin
                    next_state <= ENTRY_PROCESSING;
                    available_spaces <= available_spaces - 1;
                    count_car <= count_car + 1;
                    led_status <= 1'b0; // Available
                    seven_seg_display_available_tens <= available_spaces[9:6];
                    seven_seg_display_available_units <= available_spaces[5:0];
                    seven_seg_display_count_tens <= count_car[9:6];
                    seven_seg_display_count_units <= count_car[5:0];
                end
            end
            ENTRY_PROCESSING: begin
                if (vehicle_exit_sensor == 1'b1) begin
                    next_state <= EXIT_PROCESSING;
                    available_spaces <= available_spaces + 1;
                    count_car <= count_car - 1;
                    led_status <= 1'b1; // Full
                    seven_seg_display_available_tens <= available_spaces[9:6];
                    seven_seg_display_available_units <= available_spaces[5:0];
                    seven_seg_display_count_tens <= count_car[9:6];
                    seven_seg_display_count_units <= count_car[5:0];
                end
            end
            EXIT_PROCESSING: begin
                if (vehicle_entry_sensor == 1'b1) begin
                    next_state <= ENTRY_PROCESSING;
                    available_spaces <= available_spaces - 1;
                    count_car <= count_car + 1;
                    led_status <= 1'b0; // Available
                    seven_seg_display_available_tens <= available_spaces[9:6];
                    seven_seg_display_available_units <= available_spaces[5:0];
                    seven_seg_display_count_tens <= count_car[9:6];
                    seven_seg_display_count_units <= count_car[5:0];
                end
            end
            FULL: begin
                if (vehicle_entry_sensor == 1'b1) begin
                    next_state <= IDLE;
                    available_spaces <= available_spaces - 1;
                    count_car <= count_car + 1;
                    led_status <= 1'b1; // Full
                    seven_seg_display_available_tens <= available_spaces[9:6];
                    seven_seg_display_available_units <= available_spaces[5:0];
                    seven_seg_display_count_tens <= count_car[9:6];
                    seven_seg_display_count_units <= count_car[5:0];
                end
            end
        endcase
    end
endmodule