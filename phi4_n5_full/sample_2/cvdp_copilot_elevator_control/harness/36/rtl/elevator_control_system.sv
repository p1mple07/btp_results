module elevator_control_system #(
    parameter N = 8, // Number of floors
    parameter DOOR_OPEN_TIME_MS = 500 // Door open time in milliseconds
) (
    input wire clk,                   // 100MHz clock input
    input wire reset,                 // Active-high reset signal
    input wire [N-1:0] call_requests, // External Floor call requests
    input wire emergency_stop,        // Emergency stop signal
    input wire overload_detected,
    output wire [$clog2(N)-1:0] current_floor, // Current floor of the elevator
    output reg direction,             // Elevator direction: 1 = up, 0 = down
    output reg door_open,             // Door open signal
    output reg [2:0] system_status,    // Elevator system state indicator
    output overload_warning,          // Overload warning signal
    output [3:0] thousand,
    output [3:0] hundred,
    output [3:0] ten,
    output [3:0] one,
    output wire [6:0] seven_seg_out,    // Seven-segment display output for current floor visualization
    output wire [3:0] seven_seg_out_anode // Signal for switching between ones, tens, hundred, thousand place on seven segment
);

// State Encoding
localparam IDLE           = 3'b000;          // Elevator is idle
localparam MOVING_UP      = 3'b001;         // Elevator moving up
localparam MOVING_DOWN    = 3'b010;         // Elevator moving down
localparam EMERGENCY_HALT = 3'b011;         // Emergency halt state
localparam DOOR_OPEN      = 3'b100;         // Door open state
localparam OVERLOAD_HALT  = 3'b101;         // New state for overload condition

// Internal registers
reg [N-1:0] call_requests_internal;   // Internal copy of call requests
reg [2:0] present_state, next_state;  // FSM current and next states
reg [$clog2(N)-1:0] max_request;       // Highest requested floor
reg [$clog2(N)-1:0] min_request;        // Lowest requested floor

// Door open time configuration
`ifdef SIMULATION
    localparam CLK_FREQ_MHZ         = 100;  // Clock frequency in MHz
    localparam SIM_DOOR_OPEN_TIME_MS = 0.05; // Shorter door open time for simulation
    localparam DOOR_OPEN_CYCLES     = (SIM_DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000); // Door open cycles for simulation   
`else
    // Calculating door open cycles based on time and clock frequency
    localparam CLK_FREQ_MHZ         = 100;  // Clock frequency in MHz
    localparam DOOR_OPEN_CYCLES     = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);   // Door open cycles for real implementation
`endif

reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;   // Counter for door open duration

reg [$clog2(N)-1:0] current_floor_reg, current_floor_next = 0;

assign current_floor = current_floor_reg;

// Update overload warning signal
assign overload_warning = (overload_detected == 1 && present_state == OVERLOAD_HALT);

// FSM state transition (sequential)
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
always @(*) begin
    if (reset) begin
        max_request = 0;
        min_request = {$clog2(N){1'b1}};
    end else begin        
        max_request = 0;
        min_request = {$clog2(N){1'b1}};
        for (integer i = 0; i < N; i = i + 1) begin
            if (call_requests_internal[i]) begin
                if (i > max_request)
                    max_request = i[$clog2(N)-1:0]; 
                if (i < min_request)  
                    min_request = i[$clog2(N)-1:0]; 
            end
        end
    end
end

// FSM next state and current floor update logic (combinational)
always @(*) begin
    // Default assignments to ensure full coverage
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
            end else if (current_floor_reg >= max_request) begin
                next_state = IDLE;
            end else begin
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
            end else if (current_floor_reg <= min_request) begin
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
            if (overload_detected)
                next_state = OVERLOAD_HALT;
            else if (door_open_counter == 0)
                next_state = IDLE;
            else
                next_state = DOOR_OPEN;
        end

        OVERLOAD_HALT: begin
            if (!overload_detected)
                next_state = (door_open) ? DOOR_OPEN : IDLE;
        end

        default: begin
            next_state = present_state;
            current_floor_next = current_floor_reg;
        end
    endcase
end

// Door open control logic (sequential)
always @(posedge clk or posedge reset) begin
    if (reset)
        door_open <= 0;
    else begin
        if (present_state == OVERLOAD_HALT)
            door_open <= 1;
        else if (present_state == DOOR_OPEN) begin
            if (door_open_counter > 0)
                door_open <= 1;
            else
                door_open <= 0;
        end else
            door_open <= 0;
    end
end

// Door open counter update (sequential non-blocking)
always @(posedge clk or posedge reset) begin
    if (reset)
        door_open_counter <= DOOR_OPEN_CYCLES;
    else if (present_state == DOOR_OPEN) begin
        if (door_open_counter > 0)
            door_open_counter <= door_open_counter - 1;
        else
            door_open_counter <= DOOR_OPEN_CYCLES;
    end else
        door_open_counter <= DOOR_OPEN_CYCLES;
end

// Call request management (sequential non-blocking)
always @(posedge clk or posedge reset) begin
    if (reset)
        call_requests_internal <= 0;
    else begin
        if (call_requests_internal[current_floor_reg])
            call_requests_internal[current_floor_reg] <= 0; // Clear served request
        call_requests_internal <= call_requests_internal | call_requests; // Update requests
    end
end

// Direction control logic (combinational)
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
    .floor_display({{8-($clog2(N)){1'b0}}, current_floor_reg}),
    .seven_seg_out(seven_seg_out),
    .seven_seg_out_anode(seven_seg_out_anode),
    .thousand(thousand),
    .hundred(hundred),
    .ten(ten),
    .one(one)
);

endmodule