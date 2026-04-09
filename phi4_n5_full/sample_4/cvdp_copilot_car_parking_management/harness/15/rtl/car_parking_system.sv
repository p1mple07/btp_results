module implements a car parking management system
// - Uses an FSM to handle different states: `IDLE`, `ENTRY_PROCESSING`, `EXIT_PROCESSING`, and `FULL`.
// - Now includes a Time-Based Billing System that calculates the parking fee for exiting vehicles based on their parked duration.
//   The billing fee is computed using the function `calculate_fee` which rounds up the parked time to the next hour and multiplies by the hourly rate.
// - Entry and exit timestamps are managed via an internal register array `entry_time`, with each index corresponding to a parking slot.
// - The fee is calculated in the `EXIT_PROCESSING` state and output via `parking_fee` and `fee_ready`.

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50  // hourly fee rate (default: 50 units per hour)
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time,              // current timestamp in seconds
    input wire [($clog2(TOTAL_SPACES))-1:0] current_slot, // parking slot associated with the vehicle
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output reg [31:0] parking_fee,  // calculated parking fee for exiting vehicle
    output reg fee_ready          // indicates when the fee calculation is complete
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

    // Function to calculate parking fee based on parked time (in seconds) and hourly rate.
    // It rounds up any partial hour.
    function automatic [31:0] calculate_fee(input [31:0] parked_time, input [31:0] hourly_rate);
        calculate_fee = ((parked_time + 3599) / 3600) * hourly_rate;
    endfunction

    // Internal register array to store entry time for each parking slot.
    reg [31:0] entry_time [0:TOTAL_SPACES-1];

    // Reset logic for FSM state
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic and outputs
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
                if (available_spaces > 0)
                    next_state = IDLE;
            end
            EXIT_PROCESSING: begin
                if (count_car > 0)
                    next_state = IDLE;
            end
            FULL: begin
                if (vehicle_exit_sensor)
                    next_state = EXIT_PROCESSING;
            end
        endcase
    end

    always @(*) begin
        if (state == FULL)
            led_status = 1'b0;
        else
            led_status = 1'b1;
    end

    // Space, count, and fee management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            fee_ready <= 1'b0;
            parking_fee <= 32'd0;
        end else begin
            if (state == ENTRY_PROCESSING) begin
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
                // Store the entry time for the vehicle in the given slot.
                entry_time[current_slot] <= current_time;
            end else if (state == EXIT_PROCESSING) begin
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
                // Compute the parked duration using the stored entry time.
                reg [31:0] parked_time;
                parked_time = current_time - entry_time[current_slot];
                // Calculate the parking fee using the calculate_fee function.
                parking_fee <= calculate_fee(parked_time, PARKING_FEE_VALUE);
                // Indicate that the fee calculation is complete.
                fee_ready <= 1'b1;
                // Clear the stored entry time for the slot.
                entry_time[current_slot] <= 32'd0;
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
            end
        end
    end

    // Seven-segment display update for available spaces and car count.
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule