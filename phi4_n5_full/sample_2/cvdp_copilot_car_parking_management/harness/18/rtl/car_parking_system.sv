module implements a car parking management system with dynamic pricing,
// maximum daily fee capping, and QR code generation for payment details.
// It uses an FSM to handle different states: IDLE, ENTRY_PROCESSING, EXIT_PROCESSING, and FULL.

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 500
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time, // Current time in seconds
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot, // Slot number for the vehicle
    input wire [4:0] hour_of_day, // Hour of the day (0 to 23)
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output reg [15:0] parking_fee, // Total parking fee for the vehicle exiting
    output reg fee_ready,          // Indicates that the parking fee is ready
    output reg [127:0] qr_code      // QR code for payment details
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

    // Register for dynamic parking fee (adjusted for peak/off-peak hours)
    reg [15:0] dynamic_fee;

    // Seven-segment encoding function
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

    // Fee calculation function: rounds up to the next hour and multiplies by fee_per_hour
    function [15:0] calculate_fee;
        input [31:0] parked_time; // Total parked time in seconds
        input [15:0] fee_per_hour;
        reg [31:0] hours;
        begin
            hours = parked_time / 3600; // Convert seconds to hours
            if (parked_time % 3600 > 0) begin
                hours = hours + 1; // Round up to the next hour if there's a remainder
            end
            calculate_fee = hours * fee_per_hour;
        end
    endfunction

    // QR code generation function: Concatenates slot number, fee, and time spent
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        begin
            generate_qr_code = {slot, fee, time_spent[15:0], 80'b0}; // 128-bit QR code data
        end
    endfunction

    // FSM state update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
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

    // LED status logic
    always@(*) begin
        if(state == FULL)
            led_status = 1'b0;
        else
            led_status = 1'b1;
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
                entry_time[current_slot] <= current_time; // Store the entry time
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

    // Dynamic pricing, fee calculation, and QR code generation logic
    // This always block is triggered on the clock edge.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parking_fee_internal <= 0;
            fee_ready_internal <= 0;
            dynamic_fee <= PARKING_FEE_VALUE;
            qr_code <= 128'd0;
        end else begin
            // Update dynamic fee based on hour_of_day:
            // Double fee during peak hours (8 AM to 6 PM), otherwise use default.
            if (hour_of_day >= 8 && hour_of_day < 18)
                dynamic_fee <= PARKING_FEE_VALUE * 2;
            else
                dynamic_fee <= PARKING_FEE_VALUE;
            
            // When a vehicle exits, calculate the fee based on the parked duration.
            if (state == EXIT_PROCESSING) begin
                if (entry_time[current_slot] != 0) begin
                    // Calculate parked duration
                    reg [31:0] time_spent;
                    reg [15:0] computed_fee;
                    time_spent = current_time - entry_time[current_slot];
                    computed_fee = calculate_fee(time_spent, dynamic_fee);
                    // Cap the fee at the maximum daily fee
                    if (computed_fee > MAX_DAILY_FEE)
                        computed_fee = MAX_DAILY_FEE;
                    parking_fee_internal <= computed_fee;
                    fee_ready_internal <= 1;
                    qr_code <= generate_qr_code(parking_fee_internal, current_slot, time_spent);
                end
            end else begin
                fee_ready_internal <= 0;
            end
        end
    end

    // Drive outputs
    assign parking_fee = parking_fee_internal;
    assign fee_ready = fee_ready_internal;

    // Seven-segment display update for available spaces and vehicle count
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule