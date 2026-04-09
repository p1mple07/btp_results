`timescale 1ns / 1ps

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units
);

    // Local parameters for FSM states
    localparam IDLE            = 2'b00,
               ENTRY_PROCESSING = 2'b01,
               EXIT_PROCESSING  = 2'b10,
               FULL            = 2'b11;

    // Internal signals
    reg [1:0] state, next_state;

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

    // Space and count management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
        end else begin
            if (state == ENTRY_PROCESSING) begin
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
            end else if (state == EXIT_PROCESSING) begin
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
            end
        end
    end

    // Seven-segment display update
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

    // Time-Based Billing System
    always @(*) begin
        // Add new signals
        input wire current_time;
        input wire current_slot;

        // Internal register array
        reg [num_slots-1:0] entry_time;

        // Entry/Exit logic
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                entry_time <= {repeat(num_slots, 0)}; // initialize all to 0
            end else begin
                entry_time <= {entry_time, current_time}; // Store current_time for each slot
            end
        end

        // Exit handling
        always @(current_time) begin
            if (state == EXIT_PROCESSING) begin
                if (current_slot == 0) begin
                    entry_time[0] = current_time;
                end else begin
                    entry_time[current_slot] = current_time;
                end
            end
        end

        // Fee calculation
        always @(current_time) begin
            if (state == EXIT_PROCESSING) begin
                if (entry_time[current_slot] != 0) begin
                    integer elapsed_seconds = current_time - entry_time[current_slot];
                    integer hours = (elapsed_seconds + 3599) / 3600;
                    integer fee = hours * PARKING_FEE_VALUE;

                    $display("Parking Fee: %0.2f %s", fee, "units");
                    fee_ready = 1'b1;
                end
            end
        end
    end

endmodule
