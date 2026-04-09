// This module implements a car parking management system
// - Uses an FSM to handle different states: `IDLE`, `ENTRY_PROCESSING`, `EXIT_PROCESSING`, and `FULL`.

module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50,
    parameter MAX_DAILY_FEE = 500  // Maximum daily fee cap
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
    output reg [127:0] qr_data // Output for the QR code
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

    // Dynamic parking fee register
    reg [31:0] dynamic_fee;

    // Seven‑segment encoding
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
            dynamic_fee = hours * fee_per_hour;
            if (dynamic_fee > MAX_DAILY_FEE) dynamic_fee = MAX_DAILY_FEE;
            assign parking_fee = dynamic_fee;
            assign fee_ready = 1'b1;
        end
    endfunction

    // QR code generation function
    function [127:0] generate_qr_code;
        input [15:0] fee;
        input [$clog2(TOTAL_SPACES)-1:0] slot;
        input [31:0] time_spent;
        begin
            generate_qr_code = {slot, fee, time_spent[15:0], 80'b0};
        end
    endfunction

    // Reset logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // State machine logic
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

    // Time‑based fee adjustment
    always @(posedge clk) begin
        if (current_time >= $clog2(TOTAL_SPACES)) begin
            current_time = 0;
            state <= IDLE;
        end
    end

    // Dynamic pricing logic
    always @(*) begin
        if (state == FULL) begin
            dynamic_fee = calculate_fee;
            qr_data = {current_slot, dynamic_fee, current_time, 80'b0};
            $writepipe(qr_data, qr_output_wire);
        end
    end

    // Display and status updates
    always @(*) begin
        seven_seg_display_available_tens = seven_segment_encoding(available_spaces / 10);
        seven_seg_display_available_units = seven_segment_encoding(available_spaces % 10);
        seven_seg_display_count_tens = seven_segment_encoding(count_car / 10);
        seven_seg_display_count_units = seven_segment_encoding(count_car % 10);
    end

endmodule
