// Input signal for detecting overload
input wire overload_detected;

// Output signal for overload warning
output reg overload_warning;

// FSM state encoding
localparam IDLE = 3'b000;          // Elevator is idle
localparam MOVING_UP = 3'b001;     // Elevator moving up
localparam MOVING_DOWN = 3'b010;   // Elevator moving down
localparam EMERGENCY_HALT = 3'b011;// Emergency halt state
localparam OVERLOAD_HALT = 3'b100; // Elevator overload state
localparam DOOR_OPEN = 3'b100;     // Door open state
localparam OVERLOAD_WARNING = 3'b110; // Overload warning state

// Internal registers
reg [N-1:0] call_requests_internal;   // Internal copy of call requests
reg [2:0] present_state, next_state; // FSM current and next states
reg [$clog2(N)-1:0] max_request;     // Highest requested floor
reg [$clog2(N)-1:0] min_request;    // Lowest requested floor

// Overload warning control logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        overload_warning <= 0;
        present_state <= IDLE;
        current_floor_reg <= 0;
        max_request <= 0;
        min_request <= N-1;
    end else begin
        if (overload_detected) begin
            overload_warning <= 1;
            present_state <= OVERLOAD_WARNING;
        end else begin
            present_state <= next_state;
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
end

// FSM state transition with overload handling
always@(posedge clk or posedge reset) begin
    if (reset) begin
        present_state <= IDLE;
        current_floor_reg <= 0;
        max_request <= 0;
        min_request <= N-1;
        overload_warning <= 0;
    end else begin
        if (present_state == OVERLOAD_WARNING) begin
            next_state <= IDLE;
        end else if (present_state == IDLE) begin
            if (emergency_stop) begin
                next_state <= EMERGENCY_HALT;
            end else if (call_requests_internal != 0) begin
                if(max_request > current_floor_reg) begin
                    next_state <= MOVING_UP;
                end else if(min_request < current_floor_reg) begin
                    next_state <= MOVING_DOWN;
                end
            end
        end else if (present_state == MOVING_UP) begin
            if (emergency_stop) begin
                next_state <= EMERGENCY_HALT;
            end else if (call_requests_internal[current_floor_reg+1]) begin
                current_floor_next = current_floor_reg + 1;
                next_state = DOOR_OPEN;
            end else if (current_floor_reg >= max_request) begin
                next_state <= IDLE;
            end else begin
                current_floor_next = current_floor_reg + 1;
                next_state = MOVING_UP;
            end
        end

        if (present_state == MOVING_DOWN) begin
            if (emergency_stop) begin
                next_state <= EMERGENCY_HALT;
            end else if (call_requests_internal[current_floor_reg-1]) begin
                current_floor_next = current_floor_reg - 1;
                next_state = DOOR_OPEN;
            end else if (current_floor_reg <= min_request) begin
                next_state <= IDLE;
            end else begin
                current_floor_next = current_floor_reg - 1;
                next_state = MOVING_DOWN;
            end
        end

        if (present_state == EMERGENCY_HALT) begin
            if (!emergency_stop) begin
                next_state <= IDLE;
                current_floor_next = 0; // Optionally reset to ground floor
            end
        end

        if (present_state == DOOR_OPEN) begin
            if (door_open_counter > 0) begin
                door_open <= 1;
                door_open_counter <= door_open_counter - 1;
            end else begin
                door_open <= 0;
                next_state <= IDLE;
            end
        end
    endcase
end

// Overload warning control logic
always@(*)begin
    if (reset) begin
        call_requests_internal = 0;
    end else begin
        if (overload_detected) begin
            // Clear all active requests and transition to OVERLOAD_HALT
            call_requests_internal = 0;
            present_state <= OVERLOAD_HALT;
            overload_warning <= 1;
        end else begin
            call_requests_internal = call_requests_internal | call_requests;    // Update requests
        end
    end
end

// Seven-segment display converter instantiation
floor_to_seven_segment #(.N(8)) floor_display_converter (
    .floor_display(current_floor_reg),
    .seven_seg_out(seven_seg_out)
);
