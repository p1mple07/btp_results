module car_parking_system #(
    parameter TOTAL_SPACES = 12
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

    localparam NUM_SLOTS = 100;
    int entry_time[NUM_SLOTS];

    // Function to compute parking fee
    function int calculate_fee(int total_parked_time, int hourly_rate);
        int hours = total_parked_time / 3600;
        if (total_parked_time % 3600 != 0)
            hours += 1;
        return hours * hourly_rate;
    endfunction

    // State machine
    always @(*) begin
        if (state == FULL) begin
            led_status = 1'b0;
        end else begin
            led_status = 1'b1;
        end
    end

    // Exiting state: compute fee
    always @(*) begin
        if (state == FULL) begin
            if (vehicle_exit_sensor) begin
                int total_time = current_time - entry_time[current_slot];
                int hourly_rate = PARKING_FEE_VALUE;
                int total_hours = total_time / 3600;
                if (total_time % 3600 != 0)
                    total_hours += 1;
                int total_fee = total_hours * hourly_rate;
                parking_fee = total_fee;
                fee_ready = 1'b1;
            end
        end
    end

endmodule
