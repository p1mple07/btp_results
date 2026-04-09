module) are used.  
• Incomplete case statement coverage – a default case has been added.  
• Blocking assignments in sequential processes – the always block that computes max_request/min_request now uses a temporary integer variable and non‐blocking assignments.  
• Conflicting blocked and non‐blocking assignments – all sequential always blocks now consistently use non‐blocking assignments.

Below is the updated file (saved as rtl/elevator_control_system.sv):

--------------------------------------------------
/* rtl/elevator_control_system.sv */
module elevator_control_system #(
    parameter N = 8, // Number of floors
    parameter DOOR_OPEN_TIME_MS = 500 // Door open time in milliseconds
) (
    input  wire clk,                   // 100MHz clock input
    input  wire reset,                 // Active-high reset signal
    input  wire [N-1:0] call_requests, // External Floor call requests
    input  wire emergency_stop,        // Emergency stop signal
    input  wire overload_detected,
    output wire [$clog2(N)-1:0] current_floor, // Current floor of the elevator
    output reg  direction,             // Elevator direction: 1 = up, 0 = down
    output reg  door_open,             // Door open signal
    output reg  [2:0] system_status,    // Elevator system state indicator
    output wire overload_warning,      // Overload warning signal
    output wire [3:0] thousand,
    output wire [3:0] hundred,
    output wire [3:0] ten,
    output wire [3:0] one,
    output wire [6:0] seven_seg_out,    // Seven-segment display output for current floor visualization
    output wire [3:0] seven_seg_out_anode // Signal for switching between ones, tens, hundred, thousand place on seven segment
);

    // State Encoding
    localparam IDLE           = 3'b000;
    localparam MOVING_UP      = 3'b001;
    localparam MOVING_DOWN    = 3'b010;
    localparam EMERGENCY_HALT = 3'b011;
    localparam DOOR_OPEN      = 3'b100;
    localparam OVERLOAD_HALT  = 3'b101;

    // Internal registers
    reg [N-1:0] call_requests_internal;   // Internal copy of call requests
    reg [2:0] present_state, next_state;   // FSM current and next states
    reg [$clog2(N)-1:0] max_request;       // Highest requested floor
    reg [$clog2(N)-1:0] min_request;       // Lowest requested floor

    // Door open time configuration
    `ifdef SIMULATION
        localparam CLK_FREQ_MHZ         = 100;  // Clock frequency in MHz
        localparam SIM_DOOR_OPEN_TIME_MS= 0.05; // Shorter door open time for simulation
        localparam DOOR_OPEN_CYCLES     = (SIM_DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
    `else
        localparam CLK_FREQ_MHZ         = 100;  // Clock frequency in MHz
        localparam DOOR_OPEN_CYCLES     = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
    `endif

    reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;   // Counter for door open duration

    // Floor registers
    reg [$clog2(N)-1:0] current_floor_reg, current_floor_next;

    // Output assignment
    assign current_floor = current_floor_reg;

    // Overload warning signal
    assign overload_warning = (overload_detected && (present_state == OVERLOAD_HALT));

    // FSM state transition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state   <= IDLE;
            system_status   <= IDLE;
            current_floor_reg <= 0;
        end else begin
            present_state   <= next_state;
            system_status   <= next_state;
            current_floor_reg <= current_floor_next;
        end
    end

    // Calculate max_request and min_request based on active requests
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            max_request <= 0;
            min_request <= N-1;
        end else begin
            integer i;
            integer temp_max;
            integer temp_min;
            temp_max = 0;
            temp_min = N-1;
            for (i = 0; i < N; i = i + 1) begin
                if (call_requests_internal[i]) begin
                    if (i > temp_max)
                        temp_max = i;
                    if (i < temp_min)
                        temp_min = i;
                end
            end
            // Explicitly truncate to avoid bit-width truncation warnings
            max_request <= temp_max[$clog2(N)-1:0];
            min_request <= temp_min[$clog2(N)-1:0];
        end
    end

    // FSM next state and current_floor_next logic
    always @(*) begin
        next_state      = present_state;
        current_floor_next = current_floor_reg;
        case (present_state)
            IDLE: begin
                if (overload_detected)
                    next_state = OVERLOAD_HALT;
                else if (emergency_stop)
                    next_state = EMERGENCY_HALT;
                else if (call_requests_internal != 0) begin
                    if (max_request > current_floor_reg)
                        next_state = MOVING_UP;
                    else if (min_request < current_floor_reg)
                        next_state = MOVING_DOWN;
                end
            end
            MOVING_UP: begin
                if (emergency_stop)
                    next_state = EMERGENCY_HALT;
                else if (call_requests_internal[current_floor_reg + 1]) begin
                    current_floor_next = current_floor_reg + 1;
                    next_state = DOOR_OPEN;
                end else if (current_floor_reg >= max_request)
                    next_state = IDLE;
                else begin
                    current_floor_next = current_floor_reg + 1;
                    next_state = MOVING_UP;
                end
            end
            MOVING_DOWN: begin
                if (emergency_stop)
                    next_state = EMERGENCY_HALT;
                else if (call_requests_internal[current_floor_reg - 1]) begin
                    current_floor_next = current_floor_reg - 1;
                    next_state = DOOR_OPEN;
                end else if (current_floor_reg <= min_request)
                    next_state = IDLE;
                else begin
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
                if (overload_detected)
                    next_state = OVERLOAD_HALT;
                else if (door_open_counter == 0)
                    next_state = IDLE;
                else
                    next_state = DOOR_OPEN;
            end
            OVERLOAD_HALT: begin
                if (!overload_detected) begin
                    if (door_open)
                        next_state = DOOR_OPEN;
                    else
                        next_state = IDLE;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    // Door open control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            door_open_counter <= 0;
            door_open <= 0;
        end else begin
            if (present_state == OVERLOAD_HALT) begin
                door_open_counter <= DOOR_OPEN_CYCLES;
                door_open <= 1;
            end else if (present_state == DOOR_OPEN) begin
                if (door_open_counter > 0) begin
                    door_open <= 1;
                    door_open_counter <= door_open_counter - 1;
                end else begin
                    door_open <= 0;
                    // Next state will be updated in FSM logic
                end
            end else begin
                door_open <= 0;
                door_open_counter <= DOOR_OPEN_CYCLES; // Reset door open counter
            end
        end
    end

    // Call request management (sequential update)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            call_requests_internal <= 0;
        end else begin
            // Clear served request
            if (call_requests_internal[current_floor_reg])
                call_requests_internal[current_floor_reg] <= 0;
            // Update new requests
            call_requests_internal <= call_requests_internal | call_requests;
        end
    end

    // Direction control logic
    always @(*) begin
        if (reset)
            direction = 1;
        else begin
            if (present_state == MOVING_UP)
                direction = 1;
            else if (present_state == MOVING_DOWN)
                direction = 0;
            else
                direction = 1;
        end
    end

    // Seven-segment display converter instantiation
    floor_to_seven_segment floor_display_converter (
        .clk(clk),
        .floor_display(current_floor_reg),
        .seven_seg_out(seven_seg_out),
        .seven_seg_out_anode(seven_seg_out_anode),
        .thousand(thousand),
        .hundred(hundred),
        .ten(ten),
        .one(one)
    );

endmodule