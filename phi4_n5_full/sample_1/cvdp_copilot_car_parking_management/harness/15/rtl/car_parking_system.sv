module car_parking_system #(
    parameter TOTAL_SPACES = 12,
    parameter PARKING_FEE_VALUE = 50
)(
    input wire clk,
    input wire reset,
    input wire vehicle_entry_sensor,
    input wire vehicle_exit_sensor,
    input wire [31:0] current_time,
    input wire [3:0] current_slot,
    output reg [$clog2(TOTAL_SPACES)-1:0] available_spaces,
    output reg [$clog2(TOTAL_SPACES)-1:0] count_car,
    output reg led_status,
    output reg [6:0] seven_seg_display_available_tens,
    output reg [6:0] seven_seg_display_available_units,
    output reg [6:0] seven_seg_display_count_tens,
    output reg [6:0] seven_seg_display_count_units,
    output reg [31:0] parking_fee,
    output reg fee_ready
);

    // Internal register array to store entry time for each parking slot
    reg [31:0] entry_time [0:TOTAL_SPACES-1];

    // Local parameters for FSM states
    localparam IDLE            = 2'b00,
               ENTRY_PROCESSING = 2'b01,
               EXIT_PROCESSING  = 2'b10,
               FULL            = 2'b11;

    // Internal signals
    reg [1:0] state, next_state;

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

    // Function to calculate parking fee based on parked time and hourly rate
    function automatic [31:0] calculate_fee;
        input [31:0] total_time;
        input [31:0] hourly_rate;
        begin
            // Divide total_time by 3600 to get hours; round up if there is a remainder
            if (total_time % 3600 != 0)
                calculate_fee = ((total_time / 3600) + 1) * hourly_rate;
            else
                calculate_fee = (total_time / 3600) * hourly_rate;
        end
    endfunction

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
            default: next_state = state;
        endcase
    end

    // LED status logic
    always@(*) begin
        if(state == FULL)
            led_status = 1'b0;
        else
            led_status = 1'b1;
    end

    // Space and count management with entry time storage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spaces <= TOTAL_SPACES;
            count_car <= 0;
        end else begin
            if (state == ENTRY_PROCESSING) begin
                available_spaces <= available_spaces - 1;
                count_car <= count_car + 1;
                // Store the entry time for the current slot
                entry_time[current_slot] <= current_time;
            end else if (state == EXIT_PROCESSING) begin
                available_spaces <= available_spaces + 1;
                count_car <= count_car - 1;
                // Fee calculation will be handled in a separate block
            end else begin
                available_spaces <= available_spaces;
                count_car <= count_car;
            end
        end
    end

    // Fee calculation during EXIT_PROCESSING state
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fee_ready <= 0;
            parking_fee <= 0;
        end else begin
            if (state == EXIT_PROCESSING) begin
                // Calculate parked duration
                reg [31:0] parked_time;
                parked_time = current_time - entry_time[current_slot];
                // Calculate parking fee using the dedicated function
                parking_fee <= calculate_fee(parked_time, PARKING_FEE_VALUE);
                fee_ready <= 1;
                // Clear the stored entry time for the current slot
                entry_time[current_slot] <= 0;
            end else begin
                fee_ready <= 0;
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

endmodule