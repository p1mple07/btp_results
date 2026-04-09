// This module implements a car parking management system with time-based billing
// - Uses an FSM to handle different states: `IDLE`, `ENTRY_PROCESSING`, `EXIT_PROCESSING`, `FULL`, and `CALCULATING_FEE`.
module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire current_time,
    input wire current_slot,
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output reg [32:0] parking_fee,
    output reg fee_ready
);

    // Local parameters for FSM states
    localparam IDLE            = 2'b00,
               ENTRY_PROCESSING = 2'b01,
               EXIT_PROCESSING  = 2'b10,
               FULL            = 2'b11,
               CALCULATING_FEE  = 2'b100;

    // Internal signals
    reg [1:0] state, next_state;
    reg [32:0] entry_time;
    reg [1:0] entry_valid;

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

    // Reset logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            entry_time <= 0;
            entry_valid <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic and outputs
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
                    entry_time <= current_time;
                    entry_valid <= 1;
                end
            end
            EXIT_PROCESSING: begin
                if (count_car > 0) begin
                    next_state = IDLE;
                    entry_time <= 0;
                    entry_valid <= 0;
                end else if (state == FULL) begin
                    next_state = FULL;
                end else begin
                    next_state = CALCULATING_FEE;
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
            entry_time <= 0;
            entry_valid <= 0;
        end else begin
            if (state == ENTRY_PROCESSING) begin
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
                entry_time <= current_time;
                entry_valid <= 1;
            end else if (state == EXIT_PROCESSING) begin
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
                entry_time <= 0;
                entry_valid <= 0;
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
                entry_time <= 0;
                entry_valid <= 0;
            end
        end
    end

    // Time-based billing
    function int calculate_fee(int duration, int rate) {
        int hours;
        hours = (duration + 3599) / 3600; // Round up to next hour
        return hours * rate;
    }

    always @(*) begin
        if (state == CALCULATING_FEE) begin
            parking_fee = calculate_fee(current_time - entry_time, PARKING_FEE_VALUE);
            fee_ready = 1'b1;
        end
    end

    // Internal register array for entry times
    reg [32:0] entry_time_array[TOTAL_SPACES];
    initial begin
        for (integer i = 0; i < TOTAL_SPACES; i = i + 1) begin
            entry_time_array[i] = 0;
        end
    end

    // When vehicle exits, clear its entry time
    always @posedge current_slot #1 (posedge current_time) begin
        entry_time <= entry_time_array[current_slot];
        entry_time_array[current_slot] <= 0;
        entry_valid <= 1;
    end