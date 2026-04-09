module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 1000
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
    output [15:0] parking_fee, // Total parking fee for the vehicle exiting
    output fee_ready,          // Indicates that the parking fee is ready
    output reg [127:0] qr_output // QR code output
);

    localparam int peak_hours_start = 8;
    localparam int peak_hours_end = 18;
    localvar int hour_of_day;

    reg [1:0] state, next_state;
    reg [31:0] entry_time [TOTAL_SPACES-1:0]; // Array to store entry times for each parking space
    integer i;

    reg [15:0] parking_fee_internal;
    reg fee_ready_internal;

    // Seven‑segment encoder for the digits
    function [6:0] seven_segment_encoding;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: return 7'b1111110; // 0
                4'd1: return 7'b0110000; // 1
                4'd2: return 7'b1101101; // 2
                4'd3: return 7'b1111001; // 3
                4'd4: return 7'b0110011; // 4
                4'd5: return 7'b1011011; // 5
                4'd6: return 7'b1011111; // 6
                4'd7: return 7'b1110000; // 7
                4'd8: return 7'b1111111; // 8
                4'd9: return 7'b1111011; // 9
                default: return 7'b0000000; // Blank display
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
        end
    endfunction

    // QR code generation
    function [127:0] generate_qr_code(input [15:0] fee, input [3:0] slot, input [15:0] time_spent);
        return {slot, fee, time_spent[15:0], 80'b0};
    endfunction

    // Reset logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Dynamic fee adjustment for peak hours
    always @(posedge clk) begin
        if (state == FULL) begin
            hour_of_day = floor(current_time / 3600);
            if (hour_of_day >= peak_hours_start && hour_of_day <= peak_hours_end) begin
                parking_fee_internal = parking_fee_internal * 2;
            end
            parking_fee_internal = parking_fee_internal.signed_trunc(MAX_DAILY_FEE);
            parking_fee_internal = parking_fee_internal.unsigned_trunc(MAX_DAILY_FEE);
        end
    end

    // Fee readiness and output
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

    // Output registers
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

    assign parking_fee = parking_fee_internal;
    assign fee_ready = fee_ready_internal;
    assign qr_output = generate_qr_code(parking_fee_internal, current_slot, current_time);

endmodule
