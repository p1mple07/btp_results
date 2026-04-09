`timescale 1ns / 1ps

module elevator_control_system #(
    parameter N = 8,
    parameter DOOR_OPEN_TIME_MS = 500 // Door open time in milliseconds
) (
    input wire clk,
    input wire reset,
    input wire [N-1:0] call_requests,
    input wire emergency_stop,
    output wire [$clog2(N)-1:0] current_floor,
    output reg direction,
    output reg door_open,
    output reg [2:0] system_status,
    output wire [6:0] seven_seg_out
);

localparam OVERLOAD_HALT = 3'b111;

// New input and output signals
input overload_detected;
output overload_warning;

reg [N-1:0] call_requests_internal;
reg [2:0] present_state, next_state;
reg [$clog2(N)-1:0] max_request;
reg [$clog2(N)-1:0] min_request;
reg door_open_counter;
reg [6:0] current_floor_reg, current_floor_next;

// State encoding
localparam IDLE = 3'b000;
localparam MOVING_UP = 3'b001;
localparam MOVING_DOWN = 3'b010;
localparam EMERGENCY_HALT = 3'b011;
localparam DOOR_OPEN = 3'b100;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        present_state <= IDLE;
        system_status <= IDLE;
        current_floor_reg <= 0;
        max_request <= 0;
        min_request <= N-1;
        call_requests_internal <= 0;
        door_open_counter <= 0;
        current_floor_reg = 0;
        seven_seg_out <= 7'b0000000;
        direction = 1;
        overload_detected <= 0;
        overload_warning <= 0;
    end else begin
        present_state <= next_state;
        system_status <= next_state;
        current_floor_reg <= current_floor_next;

        // Calculate max_request and min_request
        max_request = 0;
        min_request = N-1;
        for (integer i = 0; i < N; i = i + 1) begin
            if (call_requests_internal[i]) begin
                if (i > max_request) max_request = i;
                if (i < min_request) min_request = i;
            end
        end
    end
end

always @(*) begin
    next_state = present_state;
    current_floor_next = current_floor_reg;

    case (present_state)
        IDLE: begin
            if (emergency_stop) begin
                next_state = EMERGENCY_HALT;
            end else if (call_requests_internal != 0) begin
                if (max_request > current_floor_reg) begin
                    next_state = MOVING_UP;
                } else if (min_request < current_floor_reg) begin
                    next_state = MOVING_DOWN;
                }
            end
        end

        MOVING_UP: begin
            if (emergency_stop) begin
                next_state = EMERGENCY_HALT;
            end else if (call_requests_internal[current_floor_reg+1]) begin
                current_floor_next = current_floor_reg + 1;
                next_state = DOOR_OPEN;
            } else if (current_floor_reg >= max_request) begin
                next_state = IDLE;
            end else begin
                current_floor_next = current_floor_reg + 1;
                next_state = MOVING_UP;
            end
        end

        MOVING_DOWN: begin
            if (emergency_stop) begin
                next_state = EMERGENCY_HALT;
            end else if (call_requests_internal[current_floor_reg-1]) begin
                current_floor_next = current_floor_reg - 1;
                next_state = DOOR_OPEN;
            } else if (current_floor_reg <= min_request) begin
                next_state = IDLE;
            end else begin
                current_floor_next = current_floor_reg - 1;
                next_state = MOVING_DOWN;
            end
        end

        EMERGENCY_HALT: begin
            if (!emergency_stop) begin
                next_state = IDLE;
                current_floor_next = 0;
            end
        end

        DOOR_OPEN: begin
            if (door_open_counter == 0) begin
                next_state = IDLE;
            end else begin
                next_state = DOOR_OPEN;
            end
        end

    endcase
end

// Door open control logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        door_open_counter <= 0;
        door_open <= 0;
    end else begin
        if (present_state == DOOR_OPEN) begin
            if (door_open_counter > 0) begin
                door_open <= 1;
                door_open_counter <= door_open_counter - 1;
            end else begin
                door_open <= 0;
                next_state = IDLE;
            end
        end else begin
            door_open <= 0;
            door_open_counter <= DOOR_OPEN_CYCLES;
        end
    end
end

// Call request management
always@(*)begin
    if (reset) begin
        call_requests_internal <= 0;
    end else begin
        if (call_requests_internal[current_floor_reg]) begin
            call_requests_internal[current_floor_reg] = 0;      // Clear served request
        end
        call_requests_internal = call_requests_internal | call_requests;    // Update requests
    end
end

// Direction control logic
always @(*) begin
    if (reset) begin
        direction = 1;
    end else begin
        if (present_state == MOVING_UP) begin
            direction = 1;
        } else if (present_state == MOVING_DOWN) begin
            direction = 0;
        } else begin
            direction = 1;
        end
    end
end

// Seven-segment display converter instantiation
floor_to_seven_segment #(.N(8)) floor_display_converter (
    .floor_display(current_floor_reg),
    .seven_seg_out(seven_seg_out)
);

endmodule
