module car_parking_system (
    input  logic         clk,
    input  logic         reset,
    input  logic         vehicle_entry_sensor,
    input  logic         vehicle_exit_sensor,
    output logic [SPACES_WIDTH-1:0] available_spaces,
    output logic [SPACES_WIDTH-1:0] count_car,
    output logic         led_status,
    output logic [6:0]   seven_seg_display_available_tens,
    output logic [6:0]   seven_seg_display_available_units,
    output logic [6:0]   seven_seg_display_count_tens,
    output logic [6:0]   seven_seg_display_count_units
);

    // Parameter for total parking spaces and width calculation
    parameter int TOTAL_SPACES = 12;
    parameter int SPACES_WIDTH = $clog2(TOTAL_SPACES);

    // FSM state definition
    typedef enum logic [1:0] {
        IDLE         = 2'b00,
        ENTRY_PROC   = 2'b01,
        EXIT_PROC    = 2'b10,
        FULL         = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Function to encode a 4-bit digit into a 7-segment display pattern.
    // Bit mapping: MSB = segment A, ..., LSB = segment G.
    function automatic [6:0] seg_encode(input logic [3:0] digit);
        case (digit)
            4'd0: seg_encode = 7'b0111111; // 0
            4'd1: seg_encode = 7'b0000110; // 1
            4'd2: seg_encode = 7'b1011011; // 2
            4'd3: seg_encode = 7'b1001111; // 3
            4'd4: seg_encode = 7'b1100110; // 4
            4'd5: seg_encode = 7'b1101101; // 5
            4'd6: seg_encode = 7'b1111101; // 6
            4'd7: seg_encode = 7'b0000111; // 7
            4'd8: seg_encode = 7'b1111111; // 8
            4'd9: seg_encode = 7'b1101111; // 9
            default: seg_encode = 7'b0000000;
        endcase
    endfunction

    // FSM sequential process: state register and data updates.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state   <= IDLE;
            available_spaces <= TOTAL_SPACES;
            count_car       <= 0;
        end else begin
            current_state <= next_state;
            case (next_state)
                ENTRY_PROC: begin
                    available_spaces <= available_spaces - 1;
                    count_car       <= count_car + 1;
                end
                EXIT_PROC: begin
                    available_spaces <= available_spaces + 1;
                    count_car       <= count_car - 1;
                end
                default: begin
                    // No update on IDLE or FULL states.
                end
            endcase
        end
    end

    // Next state logic for the FSM.
    always_comb begin
        // Default assignment.
        next_state = current_state;
        unique case (current_state)
            IDLE: begin
                if (vehicle_entry_sensor) begin
                    if (available_spaces != 0)
                        next_state = ENTRY_PROC;
                    else
                        next_state = FULL;
                end else if (vehicle_exit_sensor && count_car != 0)
                    next_state = EXIT_PROC;
                else
                    next_state = IDLE;
            end
            ENTRY_PROC: begin
                next_state = IDLE;
            end
            EXIT_PROC: begin
                next_state = IDLE;
            end
            FULL: begin
                if (vehicle_exit_sensor && count_car != 0)
                    next_state = EXIT_PROC;
                else
                    next_state = FULL;
            end
            default: next_state = IDLE;
        endcase
    end

    // LED status: 1 indicates parking available (available_spaces > 0), 0 indicates full.
    always_comb begin
        led_status = (available_spaces != 0);
    end

    // Compute tens and units digits for seven-segment display.
    // For numbers less than 10, tens digit is 0.
    logic [3:0] available_spaces_tens, available_spaces_units;
    logic [3:0] count_car_tens, count_car_units;

    always_comb begin
        if (available_spaces >= 10) begin
            available_spaces_tens = available_spaces - 10;
            available_spaces_units = available_spaces % 10;
        end else begin
            available_spaces_tens = 0;
            available_spaces_units = available_spaces;
        end

        if (count_car >= 10) begin
            count_car_tens = count_car - 10;
            count_car_units = count_car % 10;
        end else begin
            count_car_tens = 0;
            count_car_units = count_car;
        end
    end

    // Assign seven-segment display outputs using the seg_encode function.
    always_comb begin
        seven_seg_display_available_tens   = seg_encode(available_spaces_tens);
        seven_seg_display_available_units = seg_encode(available_spaces_units);
        seven_seg_display_count_tens       = seg_encode(count_car_tens);
        seven_seg_display_count_units      = seg_encode(count_car_units);
    end

endmodule