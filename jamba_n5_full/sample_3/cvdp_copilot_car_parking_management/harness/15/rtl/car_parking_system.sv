// Add the required parameter
parameter PARKING_FEE_VALUE = 50;

// Register array to hold the entry time for each parking slot
reg [TOTAL_SPACES-1:0] entry_time;

// Internal signals for the FSM
reg [1:0] state, next_state;

// … (rest of the existing module code remains unchanged) …

// New block for the EXIT_PROCESSING state
always @(*) begin
    if (state == FULL) begin
        // Get the entry time for the vehicle's parking slot
        int current_slot_index = current_slot;   // Replace with actual slot identifier
        int entry_time_val = entry_time[current_slot_index];

        // Calculate the elapsed time (seconds)
        int time_diff = current_time - entry_time_val;

        // Call the billing calculation function
        int fee = calculate_fee(time_diff, PARKING_FEE_VALUE);

        // Update the LED and the display
        led_status = 1'b0;
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);

        // Set the fee output
        $display("Parking Fee: %0d units", fee);

        // Signal that the calculation is ready
        fee_ready = 1'b1;
    end
end

// Helper function to compute the fee
local function calculate_fee(int total_parked_time, int rate)
    begin
        int hours = total_parked_time / 3600;
        if (total_parked_time mod 3600 != 0)
            hours += 1;
        return hours * rate;
    end
endfunction

