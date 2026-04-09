module car_parking_system #(
    parameter TOTAL_SPACES = 12
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire current_time,          // current timestamp in seconds
    input wire current_slot,          // parking slot for the vehicle
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

    // Array to store entry times for each parking slot
    reg [63:0] entry_time[63:0];

    // State variables
    reg [1:0] state, next_state;

    // Helper function to round up to the next hour
    function int calculate_fee(int total_time, int rate);
        int hours = total_time / 3600;
        return hours * rate;
    endfunction

    // Always block for clock and reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            entry_time <= {64'b0};
        end else begin
            state <= next_state;
            if (state == EXIT_PROCESSING) begin
                current_slot = current_slot;  // Read the slot from the input
                entry_time[current_slot] <= current_time;  // Record the entry time
            end
        end
    end

    // EXIT_PROCESSING: trigger fee calculation
    always @(*) begin
        if (state == EXIT_PROCESSING) begin
            current_slot = current_slot;  // Ensure the slot is read
            entry_time[current_slot] <= current_time;  // Update entry time
            next_state = IDLE;
            parking_fee <= calculate_fee(available_spaces, PARKING_FEE_VALUE);
            fee_ready <= 1'b1;
        end
    end

endmodule
