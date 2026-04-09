module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50
) (
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire current_time,
    input wire current_slot,
    output reg [6:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output reg parking_fee,
    output reg [6:0] fee_ready,
    output reg [6:0] seven_seg_display_available_tens_out,
    output reg [6:0] seven_seg_display_available_units_out,
    output reg [6:0] seven_seg_display_count_tens_out,
    output reg [6:0] seven_seg_display_count_units_out
);

    // ... previous code ...

    // New internal registers
    localparam MAX_SLOTS = 100;
    reg [MAX_SLOTS-1:0] entry_time;

    // Function to calculate fee
    function integer calculate_fee(int total_parked_seconds, int rate);
        integer hours = total_parked_seconds / 3600;
        integer remaining_seconds = total_parked_seconds % 3600;
        integer fee = (hours * rate) + (remaining_seconds * (rate / 60));
        return fee;
    endfunction

    // New always block to store entry time
    always @(vehicle_entry_sensor) begin
        entry_time[vehicle_entry_sensor] = current_time;
    end

    // New always block to clear entry time on exit
    always @(vehicle_exit_sensor) begin
        if (current_slot == entry_time[current_slot]) begin
            entry_time[current_slot] <= $random;
        end
    end

    // Always block for full state
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

    // Exit processing
    always @(*) begin
        if (state == FULL) begin
            led_status = 1'b0;
        end else begin
            led_status = 1'b1;
        end
    end

    // Parking fee calculation in exit
    always @(*) begin
        if (state == EXIT_PROCESSING) begin
            parking_fee = calculate_fee(available_spaces - 0, PARKING_FEE_VALUE);
            fee_ready = 1'b1;
        end else begin
            parking_fee = 0;
            fee_ready = 0;
        end
    end

endmodule
