module implements a car parking management system
// - Uses an FSM to handle different states: `IDLE`, `ENTRY_PROCESSING`, `EXIT_PROCESSING`, and `FULL`.
// - Adds dynamic pricing based on time of day and a maximum daily fee limit.
// - Generates a QR code with parking fee details for each vehicle.

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 1000  // Maximum daily parking fee
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time,
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot,
    input wire [31:0] hour_of_day,  // Hour of the day input
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output [15:0] parking_fee,
    output fee_ready,
    // Additional inputs for dynamic pricing
    input wire [15:0] fee_per_hour
);

    // Local parameters for FSM states
    localparam IDLE            = 2'b00,
               ENTRY_PROCESSING = 2'b01,
               EXIT_PROCESSING  = 2'b10,
               FULL            = 2'b11;

    // Internal signals
    reg [1:0] state, next_state;
    reg [31:0] entry_time [TOTAL_SPACES-1:0]; // Array to store entry times for each parking space
    reg [31:0] parked_time [TOTAL_SPACES-1:0]; // Array to store parked times for each parking space
    integer i;

    reg [1:0] state, next_state;
    reg [31:0] entry_time [TOTAL_SPACES-1:0];
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
            // Apply dynamic pricing
            if (hour_of_day >= 8 && hour_of_day <= 18) begin
                calculate_fee = calculate_fee * 2;
            end
            // Cap at maximum daily fee
            if (calculate_fee > MAX_DAILY_FEE) begin
                calculate_fee = MAX_DAILY_FEE;
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
            generate_qr_code = {slot, fee, time_spent[15:0], 80'b0}; // Include time spent in the lower bits
        end
    endfunction

    // Reset logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            parking_fee_internal = 0;
            fee_ready_internal = 0;
        end else begin
            state <= next_state;
        end
    end

    // Dynamic pricing logic
    always @(*) begin
        if (state == FULL) begin
            parking_fee = 0;
            fee_ready = 0;
            led_status = 1'b0;
            // Update displayed fees
            seven_seg_display_available_tens = seven_segment_encoding(0);
            seven_seg_display_available_units = seven_segment_encoding(0);
            seven_seg_display_count_tens = seven_segment_encoding(0);
            seven_seg_display_count_units = seven_segment_encoding(0);
        elsif (state == EXIT_PROCESSING) begin
            // Calculate parking fee
            if (count_car > 0) begin
                parked_time[current_slot] = current_time - entry_time[current_slot];
                dynamic_pricing_fee = calculate_fee(parked_time[current_slot], fee_per_hour);
                parking_fee = dynamic_pricing_fee;
                fee_ready = 1'b1;
                // Generate QR code with parking fee details
                generate_qr_code( parking_fee, current_slot, parked_time[current_slot] );
                // Update displayed fees
                seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
                seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
                seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
                seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
            end
        end
    end

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