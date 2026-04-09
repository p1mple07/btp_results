module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 100, // Added parameter for dynamic pricing
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
    output reg [15:0] parking_fee, // Total parking fee for the vehicle exiting
    output fee_ready,          // Indicates that the parking fee is ready
    output reg qr_data_ready, // Output for QR code data
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
        begin
            generate_qr_code = {slot, fee, time_spent[15:0], 80'b0};
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

    // Dynamic pricing and QR generation
    always @(*) begin
        // Determine hour of day
        integer hour_of_day;
        assign hour_of_day = current_time / 3600 % 24;

        // Apply dynamic pricing if peak hours (8 AM to 6 PM)
        if (hour_of_day >= 8 && hour_of_day < 18) begin
            parking_fee_internal = 2 * calculate_fee_base;
        end else
            parking_fee_internal = calculate_fee_base;

        // Call the qr function
        qr_data_ready = 1'b1;
        generate_qr_code = {slot, parking_fee_internal, current_time, 80'b0};
    end

    // ... rest of the code

    assign parking_fee = parking_fee_internal;
    assign fee_ready = fee_ready_internal;

    // Seven-segment display update
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule
