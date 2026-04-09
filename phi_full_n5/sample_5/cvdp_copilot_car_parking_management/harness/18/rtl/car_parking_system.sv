module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 24 * PARKING_FEE_VALUE // Assuming 24 hours for the daily limit
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
    input [31:0] hour_of_day       // Input signal for the hour of the day
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

    reg [15:0] parking_fee_internal, fee_ready_internal;

    // Register for dynamic parking fee
    reg [15:0] dynamic_fee;

    // Function for dynamic pricing
    always @(hour_of_day) begin
        if (hour_of_day >= 8'b0100000 && hour_of_day < 8'b0111111) begin
            dynamic_fee = PARKING_FEE_VALUE * 2; // Double fee for peak hours
        end else begin
            dynamic_fee = PARKING_FEE_VALUE; // Default fee
        end
    end

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
    end

    // QR code generation function
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        begin
            // Concatenate slot, fee, and time spent for QR data
            generate_qr_code = {slot, fee, time_spent[15:0], 80'b0}; // Include time spent in the lower bits
        end
    end

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

    // Fee calculation and QR code generation logic
    always @(state == EXIT_PROCESSING) begin
        // Calculate the parking fee based on the parked duration (current_time - entry_time).
        // Ensure that the fee is capped at the maximum daily fee (`MAX_DAILY_FEE`).
        reg [15:0] duration_parked;
        duration_parked = current_time - entry_time[current_slot];
        parking_fee_internal = calculate_fee(duration_parked) <= MAX_DAILY_FEE ? calculate_fee(duration_parked) : MAX_DAILY_FEE;

        // Generate a 128-bit QR code containing the parking fee, slot number, and parked duration.
        // For simplicity, the QR code data is represented as a concatenated value.
        // In a real implementation, you would use a QR code library to generate the actual QR code.
        // reg [127:0] qr_code_data = generate_qr_code(parking_fee_internal, current_slot, duration_parked);

        // Note: The QR code generation is not implemented in this example.
        // You would need to interface with a QR code library or hardware block to generate the actual QR code.
    end

    // Seven-segment display update
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

    // Update fee readiness
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fee_ready_internal = 1'b0;
        end else if (state == EXIT_PROCESSING) begin
            fee_ready_internal = 1'b1;
        end
    end

endmodule
