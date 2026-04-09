module elevator_control_system #(
    parameter N = 8,                // Number of floors
    parameter DOOR_OPEN_TIME_MS = 500 // Door open time in milliseconds
) (
    input  wire clk,                   // 100MHz clock input
    input  wire reset,                 // Active-high reset signal
    input  wire [N-1:0] call_requests, // External floor call requests
    input  wire emergency_stop,        // Emergency stop signal
    input  wire overload_detected,     // Overload detected signal
    output wire [$clog2(N)-1:0] current_floor, // Current floor of the elevator
    output reg  direction,             // Elevator direction: 1 = up, 0 = down
    output reg  door_open,             // Door open signal
    output reg  [2:0] system_status,   // Elevator system state indicator
    output overload_warning,           // Overload warning signal
    output [3:0] thousand,             // BCD digit for thousands (unused if not needed)
    output [3:0] hundred,              // BCD digit for hundreds
    output [3:0] ten,                  // BCD digit for tens
    output [3:0] one,                  // BCD digit for ones
    output wire [6:0] seven_seg_out,   // Seven-segment display output for current floor visualization
    output wire [3:0] seven_seg_out_anode // Signal for switching between BCD digit places on seven segment
);

    // State Encoding
    localparam IDLE            = 3'b000;
    localparam MOVING_UP       = 3'b001;
    localparam MOVING_DOWN     = 3'b010;
    localparam EMERGENCY_HALT  = 3'b011;
    localparam DOOR_OPEN       = 3'b100;
    localparam OVERLOAD_HALT   = 3'b101;

    // Internal registers
    reg [N-1:0] call_requests_internal;
    reg [2:0] present_state, next_state;
    reg [$clog2(N)-1:0] max_request;
    reg [$clog2(N)-1:0] min_request;

    // Door open time configuration
    `ifdef SIMULATION
        localparam CLK_FREQ_MHZ = 100;  // Clock frequency in MHz
        localparam SIM_DOOR_OPEN_TIME_MS = 0.05; // Shorter door open time for simulation
        localparam DOOR_OPEN_CYCLES = (SIM_DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
    `else
        localparam CLK_FREQ_MHZ = 100;  // Clock frequency in MHz
        localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
    `endif

    reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;

    // Register to hold current floor
    reg [$clog2(N)-1:0] current_floor_reg;
    reg [$clog2(N)-1:0] current_floor_next;

    // Continuous assignments
    assign current_floor      = current_floor_reg;
    assign overload_warning   = (overload_detected && (present_state == OVERLOAD_HALT));

    // FSM state transition (sequential process using non-blocking assignments)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state    <= IDLE;
            system_status    <= IDLE;
            current_floor_reg<= 0;
        end else begin
            present_state    <= next_state;
            system_status    <= next_state;
            current_floor_reg<= current_floor_next;
        end
    end

    // Calculate max_request and min_request (sequential process with non-blocking assignments)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            max_request <= 0;
            min_request <= N-1;
        end else begin
            max_request <= 0;
            min_request <= N-1;
            integer i;
            for (i = 0; i < N; i = i + 1) begin
                if (call_requests_internal[i]) begin
                    if (i > max_request)
                        max_request <= i;
                    if (i < min_request)
                        min_request <= i;
                end
            end
        end
    end

    // Combinational logic for next state and current_floor_next (default case added for complete coverage)
    always @(*) begin
        next_state    = present_state;
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
                else if (call_requests_internal[current_floor_reg+1])
                    current_floor_next = current_floor_reg + 1;
                else if (current_floor_reg >= max_request)
                    next_state = IDLE;
                else
                    current_floor_next = current_floor_reg + 1;
            end
            MOVING_DOWN: begin
                if (emergency_stop)
                    next_state = EMERGENCY_HALT;
                else if (call_requests_internal[current_floor_reg-1])
                    current_floor_next = current_floor_reg - 1;
                else if (current_floor_reg <= min_request)
                    next_state = IDLE;
                else
                    current_floor_next = current_floor_reg - 1;
            end
            EMERGENCY_HALT: begin
                if (!emergency_stop)
                    next_state = IDLE;
            end
            DOOR_OPEN: begin
                if (overload_detected)
                    next_state = OVERLOAD_HALT;
                else if (door_open_counter == 0)
                    next_state = IDLE;
            end
            OVERLOAD_HALT: begin
                if (!overload_detected)
                    next_state = IDLE;
            end
            default: begin
                next_state = present_state;
            end
        endcase
    end

    // Door open control logic (sequential process using non-blocking assignments; removed conflicting next_state assignment)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            door_open_counter <= 0;
            door_open        <= 0;
        end else begin
            if (present_state == OVERLOAD_HALT) begin
                door_open_counter <= DOOR_OPEN_CYCLES;
                door_open        <= 1;
            end else if (present_state == DOOR_OPEN) begin
                if (door_open_counter > 0) begin
                    door_open        <= 1;
                    door_open_counter<= door_open_counter - 1;
                end else begin
                    door_open        <= 0;
                    // Removed assignment to next_state here to avoid conflict with combinational block
                end
            end else begin
                door_open        <= 0;
                door_open_counter<= DOOR_OPEN_CYCLES;
            end
        end
    end

    // Call request management (combinational process using blocking assignments is acceptable here)
    always @(*) begin
        if (reset)
            call_requests_internal = 0;
        else begin
            if (call_requests_internal[current_floor_reg])
                call_requests_internal[current_floor_reg] = 0; // Clear served request
            call_requests_internal = call_requests_internal | call_requests; // Update requests
        end
    end

    // Direction control logic (combinational process)
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

    // Instantiate floor_to_seven_segment (excluded from review)
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