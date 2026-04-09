// Updated SystemVerilog RTL code for the car_parking_system with dynamic pricing, maximum daily pricing, and QR code generation functionality

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 100 // Define the maximum daily fee
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time, // Current time in seconds
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot, // Slot number for the vehicle
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output [15:0] parking_fee, // Total parking fee for the vehicle exiting
    output fee_ready,          // Indicates that the parking fee is ready
    input [15:0] hour_of_day, // Input signal for the hour of the day
    output reg [127:0] qr_code // Output signal for the QR code for payment
);

    // FSM states
    localparam IDLE            = 2'b00,
               ENTRY_PROCESSING = 2'b01,
               EXIT_PROCESSING  = 2'b10,
               FULL            = 2'b11;

    // Fee calculation
    reg [15:0] fee_per_hour = (hour_of_day >= 8 && hour_of_day <= 18) ? 2 * PARKING_FEE_VALUE : PARKING_FEE_VALUE; // Double fee for peak hours

    // QR code generation
    reg [127:0] qr_code_internal;

    // Dynamic pricing and fee calculation
    reg [15:0] fee_internal;
    reg fee_ready_internal;

    // Fee calculation function
    function [15:0] calculate_fee;
        input [31:0] parked_time; // Total parked time in seconds
        begin
            fee_internal = calculate_fee(parked_time, fee_per_hour);
            fee_ready_internal = (fee_internal <= MAX_DAILY_FEE) ? 1'b1 : 1'b0;
        end
    endfunction

    function [15:0] calculate_fee(input [31:0] parked_time, input [15:0] fee_per_hour);
        reg [15:0] fee = 0;
        reg [15:0] hours = parked_time / 3600; // Convert seconds to hours
        if (parked_time % 3600 > 0) begin
            hours = hours + 1; // Round up to the next hour if there's a remainder
        end
        fee = hours * fee_per_hour;
        if (fee > MAX_DAILY_FEE) begin
            fee = MAX_DAILY_FEE; // Cap the fee at the maximum daily limit
        end
        return fee;
    endfunction

    // QR code generation function
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        begin
            // Concatenate slot, fee, and time spent for QR data
            qr_code_internal = {slot, fee, time_spent[15:0], 80'h0}; // Include time spent in the lower bits
        end
    endfunction

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
            for (i = 0; i < TOTAL_SPACES; i = i + 1) begin
                entry_time[i] <= 0;
            end
        end else begin
            if (state == ENTRY_PROCESSING) begin
                entry_time[current_slot] <= current_time; // Store the entry time based on slot
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
            end else if (state == EXIT_PROCESSING) begin
                if (entry_time[current_slot] != 0) begin
                    entry_time[current_slot] <= 0; // Clear the slot
                end
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
            end
        end
    end

    // Update fee and QR code
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parking_fee_internal = 0;
            fee_ready_internal = 0;
            qr_code_internal = 0;
        end else begin
            parking_fee_internal = calculate_fee(current_time - entry_time[current_slot]);
            fee_ready_internal = fee_internal <= MAX_DAILY_FEE;
            qr_code_internal = generate_qr_code(parking_fee_internal, current_slot, current_time - entry_time[current_slot]);
        end
    end

    // Seven-segment display update
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule
