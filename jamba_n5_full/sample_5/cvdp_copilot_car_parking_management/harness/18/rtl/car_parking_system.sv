// ------------------------------------------------------------
// CAR PARKING SYSTEM - COMPLETE IMPLEMENTATION
// ------------------------------------------------------------

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 1000  // Capping threshold
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time, // Seconds since epoch
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot, // Slot number
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output [15:0] parking_fee, // Total parking fee for the vehicle exiting
    output fee_ready,          // Indicates that the parking fee is ready
    output [31:0] fee_amount   // Optional: raw fee before capping
);

    // Local parameters for FSM states
    localparam IDLE            = 2'b00,
           ENTRY_PROCESSING    = 2'b01,
           EXIT_PROCESSING     = 2'b10,
           FULL              = 2'b11;

    // Internal signals
    reg [1:0] state, next_state;
    reg [31:0] entry_time [TOTAL_SPACES-1:0]; // Entry times for each slot
    integer i;

    reg [15:0] parking_fee_internal;
    reg fee_ready_internal;

    // Dynamic fee calculation helpers
    function int int_hours(int time_in_sec);
        return time_in_sec / 3600;
    endfunction

    function int int_minutes(int time_in_sec);
        return (time_in_sec % 3600) / 60;
    endfunction

    // Calculate parking fee with dynamic pricing
    function int calculate_fee();
        int h = int_hours(current_time);
        int m = int_minutes(current_time);
        if (h >= 8 && h < 18) begin
            PARKING_FEE_VALUE = PARKING_FEE_VALUE * 2;
        end
        hours = h;
        if (parked_time > 0) begin
            hours = parked_time / 3600;
        end
        if (hours > MAX_DAILY_FEE / PARKING_FEE_VALUE) begin
            PARKING_FEE_VALUE = MAX_DAILY_FEE;
        end
        return hours * PARKING_FEE_VALUE;
    endfunction

    // QR code generation
    function [127:0] generate_qr_code();
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        generate
            $display("Slot: %0d, Fee: %0d, Time: %0d", slot, fee, time_spent);
            return {slot, fee, time_spent[15:0], 80'b0};
        end
    endfunction

    // State machine transitions
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Entry/Exit state handling
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

    // Fee update
    always @(posedge clk) begin
        if (state == FULL) begin
            led_status = 1'b0;
        end else begin
            led_status = 1'b1;
        end
    end

    // Display the seven‑segment digits
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule
