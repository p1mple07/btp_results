module car_parking_system (
    input                 clk,
    input                 reset,
    input                 vehicle_entry_sensor,
    input                 vehicle_exit_sensor,
    output reg [6:0]     available_spaces,
    output reg [6:0]     count_car,
    output reg            led_status,
    output reg [6:0]     seven_seg_available_tens,
    output reg [6:0]     seven_seg_available_units,
    output reg [6:0]     seven_seg_count_tens,
    output reg [6:0]     seven_seg_count_units
);

// State definitions
localparam IDLE = 3'd0,
              ENTRY = 3'd1,
              EXIT  = 3'd2,
              FULL  = 3'd3;

// Counters
reg [6:0] available_counter;
reg [6:0] car_counter;

// LED status
reg led_status_reg;

// Seven‑segment encoders (simplified for the required digits)
function [6:0] seg_digit(int value, int seg_a, int seg_b, int seg_c, int seg_d, int seg_e, int seg_f, int seg_g);
    assign [6:0] out = {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g};
endfunction

always @(posedge clk or posedge reset) begin
    if (reset) begin
        available_counter <= 7;
        count_car <= 0;
        led_status_reg <= 1;
        seven_seg_available_tens <= 1;
        seven_seg_available_units <= 2;
        seven_seg_count_tens <= 0;
        seven_seg_count_units <= 0;
    end else begin
        case (state)
            IDLE: begin
                available_counter <= 12;
                count_car <= 0;
                led_status_reg <= 1;
                seven_seg_available_tens <= 1;
                seven_seg_available_units <= 2;
                seven_seg_count_tens <= 0;
                seven_seg_count_units <= 0;
            end

            ENTRY: begin
                available_counter <= available_counter - 1;
                count_car <= count_car + 1;
                available_spaces = available_counter;
                count_car = count_car;
                // Update 7‑segment displays
                seven_seg_available_tens <= seg_digit(available_spaces / 10, 1, 0, 1, 1, 1, 1, 1);
                seven_seg_available_units <= seg_digit(available_spaces % 10, 0, 0, 0, 0, 0, 0, 0);
                seven_seg_count_tens <= seg_digit(count_car / 10, 1, 1, 1, 1, 1, 1, 1);
                seven_seg_count_units <= seg_digit(count_car % 10, 0, 0, 0, 0, 0, 0, 0);
            end

            EXIT: begin
                available_counter <= 7;
                count_car <= 0;
                led_status_reg <= 0;
                seven_seg_available_tens <= 0;
                seven_seg_available_units <= 0;
                seven_seg_count_tens <= 0;
                seven_seg_count_units <= 0;
            end

            FULL: begin
                available_counter <= 0;
                count_car <= 0;
                led_status_reg <= 0;
                seven_seg_available_tens <= 0;
                seven_seg_available_units <= 0;
                seven_seg_count_tens <= 0;
                seven_seg_count_units <= 0;
            end
        endcase
    end
end

always @(*) begin
    available_spaces = available_counter;
    count_car = car_counter;
    led_status = available_spaces > 0;
end

endmodule
