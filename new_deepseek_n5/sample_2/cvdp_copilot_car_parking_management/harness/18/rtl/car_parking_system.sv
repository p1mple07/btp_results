module implements a car parking management system
// - Uses an FSM to handle different states: `IDLE`, `ENTRY_PROCESSING`, `EXIT_PROCESSING`, and `FULL`.
// - Adds dynamic pricing based on time of day, maximum daily pricing, and QR code generation.

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 100  // Maximum allowed daily parking fee
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time,
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot,
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output led_status,
    output [6:0] seven_seg_display_available_tens,
    output [6:0] seven_seg_display_available_units,
    output [6:0] seven_seg_display_count_tens,
    output [6:0] seven_seg_display_count_units,
    output [15:0] parking_fee,
    output fee_ready,
    input [31:0] hour_of_day,  // Hour of the day input
    // Internal signals
    reg [1:0] state, next_state;
    reg [31:0] entry_time [TOTAL_SPACES-1:0]; // Array to store entry times for each parking space
    reg [15:0] parking_fee_internal;
    reg fee_ready_internal;

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

    // Calculate parking fee based on time spent and peak hours
    function [15:0] calculate_fee;
        input [31:0] parked_time;
        input [15:0] fee_per_hour;
        input [8:0] is_peakHour;
        begin
            hours = parked_time / 3600;
            if (parked_time % 3600 > 0) begin
                hours = hours + 1; // Round up to next hour
            end
            if (is_peakHour) begin
                parking_fee_internal = hours * (fee_per_hour * 2);
            else begin
                parking_fee_internal = hours * fee_per_hour;
            end
            parking_fee_internal = min(parking_fee_internal, MAX_DAILY_FEE);
        end
    endfunction

    // QR code generation function
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        input [8:0] is_peakHour;
        begin
            // Concatenate slot, fee, time spent, and peak hour info for QR data
            generate_qr_code = {slot, fee, time_spent[15:0], 80'b0, is_peakHour};
        end
    endfunction

    // FSM state transitions
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (vehicle_entry_sensor && available_spaces > 0) begin
                    next_state = ENTRY_PROCESSING;
                end else if (vehicle_exit_sensor && count_car > 0) begin
                    next_state = EXIT_PROCESSING;
                end else if (available_spaces == 0) begin
                    next_state = FULL;
                end
            end
            ENTRY_PROCESSING: begin
                if (available_spaces > 0) begin
                    next_state = IDLE;
                end
            end
            EXIT_PROCESSING: begin
                if (entry_time[current_slot] != 0) begin
                    next_state = IDLE;
                end
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
            end
            FULL: begin
                if (vehicle_exit_sensor) begin
                    next_state = EXIT_PROCESSING;
                end
            end
        endcase
    end

    // Update LED status
    always @(*) begin
        led_status = (available_spaces == 0) ? 1'b0 : 1'b1;
    end

    // Space and count management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            for (i = 0; i < TOTAL_SPACES; i = i + 1) begin
                entry_time[i] <= 0;
            end
        end else begin
            if (state == ENTRY_PROCESSING) begin
                entry_time[current_slot] <= current_time;
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
            end else if (state == EXIT_PROCESSING) begin
                if (entry_time[current_slot] != 0) begin
                    entry_time[current_slot] <= 0;
                end
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
            end
        end
    end

    // Calculate parking fee and generate QR code
    always @(*) begin
        if (state == FULL) begin
            led_status = 1'b0;
        else begin
            led_status = 1'b1;
        end
    end

    // Assign parking fee and readiness
    assign parking_fee = parking_fee_internal;
    assign fee_ready = 1;

    // Update seven-segment displays
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end
endmodule