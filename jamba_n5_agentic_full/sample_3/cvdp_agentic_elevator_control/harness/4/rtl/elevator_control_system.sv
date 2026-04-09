module elevator_control_system #(
    parameter N = 8,
    parameter DOOR_OPEN_TIME_MS = 500,
    parameter OVERLOAD = 1, // Enable overload detection
    parameter DOOR_OPEN_TIME_MS = 500,
    parameter DOOR_OPEN_CYCLES = 10000 // for simulation
) (
    input wire clk,
    input wire reset,
    input wire [N-1:0] call_requests,
    input wire emergency_stop,
    output wire [$clog2(N)-1:0] current_floor,
    output reg direction,
    output reg door_open,
    output reg [2:0] system_status,
    output reg up_led,
    output reg down_led,
    output reg overload_led
);

    typedef enum logic [2:0] {
        IDLE           = 3'b000,
        MOVING_UP      = 3'b001,
        MOVING_DOWN    = 3'b010,
        EMERGENCY_HALT = 3'b011,
        DOOR_OPEN   = 3'b100
    } state_t;

    state_t state, next_state;

    reg [N-1:0] call_requests_internal;   // Internal copy
    reg [$clog2(N)-1:0] max_request;     // Highest requested floor
    reg [$clog2(N)-1:0] min_request;    // Lowest requested floor
    reg overload_flag; // for simulation

    // Door open time configuration
    localparam CLK_FREQ_MHZ = 100;
    localparam SIM_DOOR_OPEN_TIME_MS = 0.05;
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);

    // State transitions
    always_ff @(posedge clk or posedge reset) begin
        if(reset)begin
            state <= IDLE;
            system_status <= IDLE;
            current_floor_reg <= 0;
            max_request <= 0;
            min_request <= N-1;
            overload_flag <= 0;
            door_open_counter <= 0;
            door_open <= 0;
            door_open_cycles <= 0;
            up_led <= 0;
            down_led <= 0;
            overload_led <= 0;
        end else begin
            state <= next_state;
            system_status <= next_state;
            current_floor_reg <= current_floor_next;

            // Calculate max_request and min_request based on active requests
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

    always_comb begin
        next_state = state;
        current_floor_next = current_floor_reg;

        case(state)
            IDLE:begin
                if(emergency_stop)begin
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
                    // If we reach the highest request, go idle
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
                    // If we reach the lowest request, go idle
                    next_state = IDLE;
                end else begin
                    current_floor_next = current_floor_reg - 1;
                    next_state = MOVING_DOWN;
                end
            end

            EMERGENCY_HALT: begin
                if (!emergency_stop) begin
                    next_state = IDLE;
                    current_floor_next = 0; // Optionally reset to ground floor
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

    always_comb begin
        next_state = state;
        current_floor_next = current_floor_reg;

        case(state)
            IDLE:begin
                if(emergency_stop)begin
                    next_state = EMERGENCY_HALT;
                end else if(call_requests_internal != 0)begin
                    if(overload)begin
                        next_state = DOOR_OPEN;
                        next_state = {DOOR_OPEN_LED, OVERLOAD_LED};
                        overload_flag <= 1;
                    end else begin
                        next_state = IDLE;
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
                    // If we reach the highest request, go idle
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
                    // If we reach the lowest request, go idle
                    next_state = IDLE;
                end else begin
                    current_floor_next = current_floor_reg - 1;
                    next_state = MOVING_DOWN;
                end
            end

            EMERGENCY_HALT: begin
                if (!emergency_stop) begin
                    next_state = IDLE;
                    current_floor_next = 0; // Optionally reset to ground floor
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
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            door_open_counter <= 0;
            door_open <= 0;
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
                door_open_counter <= DOOR_OPEN_CYCLES; // Reset door open counter
            end
        end
    end

    // Call request management
    always_comb begin
        if(reset) begin
            call_requests_internal = 0;
        end else begin
            if(call_requests_internal[current_floor_reg])begin
                call_requests_internal[current_floor_reg] = 0;      // Clear served request
            end
            call_requests_internal = call_requests_internal | call_requests;    // Update requests
        end
    end

    // Direction control logic
    always_comb begin
        if (reset) direction = 1;
        else if (state == MOVING_UP) direction = 1;
        else if (state == MOVING_DOWN) direction = 0;
        else direction = 1;
    end

endmodule
