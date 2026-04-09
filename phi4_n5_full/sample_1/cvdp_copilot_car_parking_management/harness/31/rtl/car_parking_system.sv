module implements a car parking management system
// - Uses an FSM to handle different states: IDLE, ENTRY_PROCESSING, EXIT_PROCESSING, and FULL.
// - Tracks vehicle entries/exits, parking fee calculation, and warning alerts.
// - Dynamically adjusts fees based on time-of-day and uses a synthesizable blinking LED for warnings.

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 500,
    parameter WARNING_LIMIT = 12 * 3600, // 12 hours in seconds
    parameter OVERSTAY_LIMIT = 24 * 3600 // 24 hours in seconds
)(
    input wire clk,
    input wire reset,
    input wire clear,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time, // Current time in seconds
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot, // Slot number for the vehicle
    input wire [4:0] hour_of_day, // Current hour of the day (0-23), provided externally
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output reg [15:0] parking_fee, // Total parking fee for the vehicle exiting
    output reg fee_ready,          // Indicates that the parking fee is ready
    output reg [127:0] qr_code, // QR code data for parking fee payment
    output time_warning_alert, // Alert if parked beyond WARNING_LIMIT
    output reg led_warning // Blinking LED for warning
);

    // Local parameters for FSM states
    localparam IDLE            = 2'b00,
               ENTRY_PROCESSING = 2'b01,
               EXIT_PROCESSING  = 2'b10,
               FULL            = 2'b11;

    // Internal signals
    reg [1:0] state, next_state;
    reg [31:0] entry_time [TOTAL_SPACES-1:0]; // Array to store entry times for each parking space
    integer i;

    // Dynamic fee adjustment register
    reg [15:0] dynamic_parking_fee;

    // Seven-segment encoding function
    function [6:0] seven_segment_encoding;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: seven_segment_encoding = 7'b1111110; // 0
                4'd1: seven_segment_encoding = 7'b0110000; // 1
                4'd2: seven_segment_encoding = 7'b1101101; // 2
                4'd3: seven_segment_encoding = 7'b1111001; // 3
                4'd4: seven_segment_encoding = 7'b0110011; // 4
                4'd5: seven_segment_encoding = 7'b1011011; // 5
                4'd6: seven_segment_encoding = 7'b1011111; // 6
                4'd7: seven_segment_encoding = 7'b1110000; // 7
                4'd8: seven_segment_encoding = 7'b1111111; // 8
                4'd9: seven_segment_encoding = 7'b1111011; // 9
                default: seven_segment_encoding = 7'b0000000; // Blank display
            endcase
        end
    endfunction

    // Fee calculation function
    function [15:0] calculate_fee;
        input [31:0] parked_time; // Total parked time in seconds
        input [15:0] fee_per_hour;
        begin
            // Convert seconds to hours and round up if necessary
            if (parked_time % 3600 > 0) begin
                calculate_fee = ((parked_time / 3600) + 1) * fee_per_hour;
            end else begin
                calculate_fee = (parked_time / 3600) * fee_per_hour;
            end
        end
    endfunction

    // QR code generation function
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        begin
            // Concatenate slot, fee, and time spent for QR data
            generate_qr_code = {slot, fee, time_spent, {128- ($clog2(TOTAL_SPACES) + 16 + 32){1'b0}}};
        end
    endfunction

    // FSM state update
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Dynamic fee adjustment based on hour of day (combinational)
    always @(*) begin
        if (hour_of_day >= 8 && hour_of_day <= 18)
            dynamic_parking_fee = PARKING_FEE_VALUE * 2; // Peak hours: double the fee
        else
            dynamic_parking_fee = PARKING_FEE_VALUE; // Regular hours
    end

    // Next state logic and outputs (combinational)
    always @(*) begin
        // Defaults
        next_state = state;
        case (state)
            IDLE: begin
                if (vehicle_entry_sensor && available_spaces > 0)
                    next_state = ENTRY_PROCESSING;
                else if (vehicle_exit_sensor && count_car > 0)
                    next_state = EXIT_PROCESSING;
                else if (available_spaces == 0)
                    next_state = FULL;
            end
            ENTRY_PROCESSING: begin
                next_state = IDLE;
            end
            EXIT_PROCESSING: begin
                if (clear)
                    next_state = IDLE;
                else if (time_warning_alert == 1'b1)
                    next_state = EXIT_PROCESSING;
                else
                    next_state = IDLE;
            end
            FULL: begin
                next_state = (vehicle_exit_sensor) ? EXIT_PROCESSING : FULL;
            end
        endcase
    end

    // LED Status Control (combinational)
    always @(*) begin
        led_status = (state != FULL);
    end

    // Space and count management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            for (i = 0; i < TOTAL_SPACES; i = i + 1)
                entry_time[i] <= 0;
        end else begin
            if (state == ENTRY_PROCESSING) begin
                entry_time[current_slot] <= current_time; // Store the entry time based on slot
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
            end else if (state == EXIT_PROCESSING) begin
                entry_time[current_slot] <= 0; // Clear the slot
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
            end
        end
    end

    // Time warning alert generation
    assign time_warning_alert = (((current_time - entry_time[current_slot]) > WARNING_LIMIT) &&
                                  ((current_time - entry_time[current_slot]) < OVERSTAY_LIMIT)) &&
                                  (!clear) ? 1'b1 : 1'b0;

    // Blinking LED for warning using a counter (synthesizable blinking)
    reg [3:0] blink_counter;
    always @(posedge clk) begin
        if (state == EXIT_PROCESSING) begin
            if (time_warning_alert) begin
                blink_counter <= blink_counter + 1;
                if (blink_counter == 4'd15) begin
                    blink_counter <= 4'd0;
                    led_warning <= ~led_warning;
                end
            end else begin
                led_warning <= 0;
                blink_counter <= 4'd0;
            end
        end else begin
            led_warning <= 0;
            blink_counter <= 4'd0;
        end
    end

    // Fee calculation and QR code generation
    always @(posedge clk) begin
        if (state == EXIT_PROCESSING) begin
            if (calculate_fee(current_time - entry_time[current_slot], dynamic_parking_fee) > MAX_DAILY_FEE) begin
                parking_fee <= MAX_DAILY_FEE; // Cap fee at maximum daily value
                qr_code <= generate_qr_code(MAX_DAILY_FEE, current_slot, current_time - entry_time[current_slot]);
            end else begin
                parking_fee <= calculate_fee(current_time - entry_time[current_slot], dynamic_parking_fee);
                qr_code <= generate_qr_code(calculate_fee(current_time - entry_time[current_slot], dynamic_parking_fee),
                                            current_slot,
                                            current_time - entry_time[current_slot]);
            end
        end else begin
            parking_fee <= 0;
            qr_code <= 128'b0; // Clear QR code data
        end
    end

    // Fee ready signal
    always @(posedge clk) begin
        fee_ready <= (state == EXIT_PROCESSING);
    end

    // Seven-segment display update (combinational)
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule