module implements a car parking management system
// - Uses an FSM to handle different states: `IDLE`, `ENTRY_PROCESSING`, `EXIT_PROCESSING`, and `FULL`.
// - Dynamic pricing based on time of day (peak hours: 8 AM-6 PM doubled)
// - Maximum daily fee capping
// - QR code generation for parking fees

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 200
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time,
    input wire [$clog2(TOTAL_SPACES)-1:0] current_slot,
    input wire [31:0] hour_of_day,
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output [15:0] parking_fee,
    output [15:0] fee_ready,
    output [15:0] dynamic_parking_fee,
    output [15:0] qr_code
);

    // Local parameters for FSM states
    localparam IDLE            = 2'b00,
               ENTRY_PROCESSING = 2'b01,
               EXIT_PROCESSING  = 2'b10,
               FULL            = 2'b11;

    // Internal signals
    reg [1:0] state, next_state;
    reg [31:0] entry_time [TOTAL_SPACES-1:0];
    reg [15:0] parking_fee_internal;
    reg fee_ready_internal;
    reg [15:0] dynamic_parking_fee_internal;

    // Hour calculation
    integer current_hour = current_time / 3600;
    current_hour = current_hour % 24;

    // Dynamic pricing logic
    always @(*) begin
        if (state == IDLE || state == FULL) begin
            dynamic_parking_fee = 0;
        end else if (state == ENTRY_PROCESSING) begin
            dynamic_parking_fee = parking_fee_value;
        end else if (state == EXIT_PROCESSING && (current_hour >= 8 && current_hour <= 18)) begin
            dynamic_parking_fee = parking_fee_value * 2;
        end else if (state == EXIT_PROCESSING) begin
            dynamic_parking_fee = 0;
        end

        // Cap at maximum daily fee
        if (dynamic_parking_fee > MAX_DAILY_FEE) begin
            dynamic_parking_fee = MAX_DAILY_FEE;
        end
    end

    // QR code generation function
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        begin
            // Concatenate slot, fee, and time spent for QR data
            qr_code = {slot, fee, time_spent[15:0], 80'b0};
        end
    endfunction

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
        endcase
    end

    always@(*)begin
        if(state == FULL) begin
            led_status = 1'b0;
        end else begin
            led_status = 1'b1;
        end
    end

    // Space and count management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
            dynamic_parking_fee = 0;
            qr_code = 0;
            for (i = 0; i < TOTAL_SPACES; i = i + 1) begin
                entry_time[i] <= 0;
            end
        end else begin
            if (state == ENTRY_PROCESSING) begin
                entry_time[current_slot] <= current_time;
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
                dynamic_parking_fee <= 0;
            end else if (state == EXIT_PROCESSING) begin
                if (entry_time[current_slot] != 0) begin
                    entry_time[current_slot] <= 0;
                end
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
                dynamic_parking_fee <= 0;
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
                dynamic_parking_fee <= 0;
            end
        end
    end

    // QR code generation
    always @posedge clk begin
        if (state == EXIT_PROCESSING) begin
            qr_code = generate_qr_code(dynamic_parking_fee, current_slot, current_time - entry_time[current_slot]);
            fee_ready = 1;
        end
    end

    assign parking_fee = dynamic_parking_fee;
    assign fee_ready = fee_ready_internal;
    assign qr_code;

    // Seven-segment display update
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule