// rtl/elevator_control_system.sv
`timescale 1ns / 1ps

module elevator_control_system #(
    parameter N = 8,
    parameter DOOR_OPEN_TIME_MS = 500
) (
    input wire clk,
    input wire reset,
    input wire [N-1:0] call_requests,
    input wire emergency_stop,
    output wire [$clog2(N)-1:0] current_floor,
    output reg direction,
    output reg door_open,
    output reg [2:0] system_status,
    output reg overload_led,
    output reg up_led,
    output reg down_led
);

    typedef enum logic [2:0] {
        IDLE           = 3'b000,
        MOVING_UP      = 3'b001,
        MOVING_DOWN    = 3'b010,
        EMERGENCY_HALT = 3'b011,
        DOOR_OPEN   = 3'b100
    } state_t;

    state_t state, next_state;

// Internal registers
reg [N-1:0] call_requests_internal;   // Internal copy of call requests
reg [$clog2(N)-1:0] max_request;     // Highest requested floor
reg [$clog2(N)-1:0] min_request;    // Lowest requested floor

// Door open time configuration
localparam CLK_FREQ_MHZ = 100;
localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);

// Counter for door open duration
reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;

// State machine variables
reg [$clog2(DOOR_OPEN_CYCLES)-1:0] current_floor_reg, current_floor_next=0;

// Initial values
initial begin
    state <= IDLE;
    system_status <= IDLE;
    current_floor_reg <= 0;
    max_request <= 0;
    min_request <= N-1;
    door_open_counter <= 0;
end

// FSM state transition
always_ff @(posedge clk or posedge reset) begin
    if(reset)begin
        state <= IDLE;
        system_status <= IDLE;
        current_floor_reg <= 0;
        max_request <= 0;
        min_request <= N-1;
        door_open_counter <= 0;
        current_floor_next <= 0;
    end else begin
        state <= next_state;
        system_status <= next_state;
        current_floor_reg <= current_floor_next;
        
        // Compute max and min requests based on active calls
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

// Door open control logic
always_comb begin
    next_state = state;
    current_floor_next = current_floor_reg;

    case(state)
        IDLE: begin
            if (emergency_stop)begin
                next_state = EMERGENCY_HALT;
            end else if(call_requests_internal != 0)begin
                if(max_request > current_floor_reg)begin
                    next_state = MOVING_UP;
                end else if(min_request < current_floor_reg) begin
                    next_state = MOVING_DOWN;
                end
            end
        end

        MOVING_UP: begin
            if(emergency_stop)begin
                next_state = EMERGENCY_HALT;
            end else if(call_requests_internal[current_floor_reg+1]) begin
                current_floor_next = current_floor_reg + 1;
                next_state = DOOR_OPEN;
            end else if(current_floor_reg >= max_request) begin
                // Move up and keep doors open
                next_state = IDLE;
            end else begin
                current_floor_next = current_floor_reg + 1;
                next_state = MOVING_UP;
            end
        end

        MOVING_DOWN: begin
            if(emergency_stop)begin
                next_state = EMERGENCY_HALT;
            end else if(call_requests_internal[current_floor_reg-1]) begin
                current_floor_next = current_floor_reg - 1;
                next_state = DOOR_OPEN;
            end else if(current_floor_reg <= min_request) begin
                // Move down and keep doors open
                next_state = IDLE;
            end else begin
                current_floor_next = current_floor_reg - 1;
                next_state = MOVING_DOWN;
            end
        end

        EMERGENCY_HALT: begin
            if (!emergency_stop) begin
                next_state = IDLE;
                current_floor_next = 0; // Reset to ground floor
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

// Overload and directional LEDs
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        door_open_counter <= 0;
        door_open <= 0;
        overload_led <= 0;
        up_led <= 0;
        down_led <= 0;
    end else begin
        if (state == DOOR_OPEN) begin
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

always_comb begin
    case(state)
        IDLE: begin
            if (overload) begin
                next_state = DOOR_OPEN;
                overload_led = 1;
            end else begin
                next_state = IDLE;
            end
        end

        MOVING_UP: begin
            if (overload) begin
                next_state = DOOR_OPEN;
                overload_led = 1;
            end else if (current_floor_reg >= max_request) begin
                next_state = IDLE;
            end
        end

        MOVING_DOWN: begin
            if (overload) begin
                next_state = DOOR_OPEN;
                overload_led = 1;
            end else if (current_floor_reg <= min_request) begin
                next_state = IDLE;
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

// Output declarations
output reg up_led, down_led, overload_led;

endmodule
