module implements a car parking management system
// - Uses an FSM to handle different states: `IDLE`, `ENTRY_PROCESSING`, `EXIT_PROCESSING`, and `FULL`.
// - Adds dynamic pricing functionality with peak hour (8 AM-6 PM) doubling.
// - Implements maximum daily pricing capping.
// - Generates QR code with parking fee details.

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 1000,
    // Input signal for hour of the day (0-23)
    input wire [3:0] hour_of_day
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time,
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot,
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output [15:0] parking_fee,
    output fee_ready,
    output [3:0] hour_of_day_ind  // Internal signal for hour_of_day input
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

    reg [15:0] parking_fee_internal;
    reg fee_ready_internal;

    // Dynamic pricing parameters
    reg [15:0] dynamic_pricing_fee;

    // Seven-segment encoding
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

    reg [31:0] hours = 0;

    // Fee calculation function
    function [15:0] calculate_fee;
        input [31:0] parked_time; // Total parked time in seconds
        input [15:0] fee_per_hour;
        begin
            hours = parked_time / 3600; // Convert seconds to hours
            if (parked_time % 3600 > 0) begin
                hours = hours + 1; // Round up to the next hour if there's a remainder
            end
            calculate_fee = hours * fee_per_hour;
        end
    endfunction

    // QR code generation function
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        input [3:0] hour_of_day_flag;
        begin
            // Concatenate slot, fee, and time spent for QR data
            generate_qr_code = {slot, fee, time_spent[15:0], 80'b0, hour_of_day_flag};
            // Include time spent in the lower bits
        end
    endfunction

    // Reset logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            hour_of_day_ind <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Dynamic pricing logic
    always @(*) begin
        // Defaults
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
                if (count_car > 0) begin
                    next_state = IDLE;
                end
            end
            FULL: begin
                if (vehicle_exit_sensor) begin
                    next_state = EXIT_PROCESSING;
                end
            end
        endcase
    end

    always@(*)begin
        if(state == FULL) begin
            led_status = 1'b0;
        end else begin
            led_status = 1'b1;
        end
    end

    // Space and count management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            for (i = 0; i < TOTAL_SPACES; i = i + 1) begin
                entry_time[i] <= 0;
            end
            hour_of_day_ind <= 0;
        end else begin
            if (state == ENTRY_PROCESSING) begin
                entry_time[current_slot] <= current_time; // Store the entry time based on slot
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
                hour_of_day_ind <= (hour_of_day >> 1) & 3; // Update hour for next state
            end else if (state == EXIT_PROCESSING) begin
                if (entry_time[current_slot] != 0) begin
                    entry_time[current_slot] <= 0; // Clear the slot
                end
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
                hour_of_day_ind <= (hour_of_day >> 1) & 3; // Update hour for next state
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
                hour_of_day_ind <= (hour_of_day >> 1) & 3; // Update hour for next state
            end
        end
    end

    // Dynamic pricing calculation
    always @(*) begin
        if (state == ENTRY_PROCESSING && !reset) begin
            if (hour_of_day_ind == 0 || hour_of_day_ind == 1) begin // 8 AM - 9 AM
                dynamic_pricing_fee = calculate_fee * 2;
            else if (hour_of_day_ind == 2 || hour_of_day_ind == 3) begin // 10 AM - 11 AM
                dynamic_pricing_fee = calculate_fee * 2;
            else if (hour_of_day_ind == 4 || hour_of_day_ind == 5) begin // 12 PM - 1 PM
                dynamic_pricing_fee = calculate_fee * 2;
            else if (hour_of_day_ind == 6 || hour_of_day_ind == 7) begin // 2 PM - 3 PM
                dynamic_pricing_fee = calculate_fee * 2;
            else if (hour_of_day_ind == 8 || hour_of_day_ind == 9) begin // 4 PM - 5 PM
                dynamic_pricing_fee = calculate_fee * 2;
            else if (hour_of_day_ind == 10 || hour_of_day_ind == 11) begin // 6 PM - 7 PM
                dynamic_pricing_fee = calculate_fee * 2;
            end
            parking_fee_internal = dynamic_pricing_fee;
        end
    end

    // Maximum daily pricing
    always @(*)begin
        if (state == IDLE || state == ENTRY_PROCESSING) begin
            if (parking_fee_internal > MAX_DAILY_FEE) begin
                parking_fee_internal = MAX_DAILY_FEE;
            end
        end
    end

    // QR code generation
    always @(*)begin
        if (state == IDLE || state == ENTRY_PROCESSING) begin
            generate_qr_code = {available_spaces, parking_fee, current_time[15:0], 80'b0, hour_of_day_ind};
        end
    end

    assign parking_fee = parking_fee_internal;
    assign fee_ready = fee_ready_internal;
    assign seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
    assign seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
    assign seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
    assign seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
endmodule