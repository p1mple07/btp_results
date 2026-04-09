module elevator_control_system #(
    parameter N = 8, //Number of floors
    parameter DOOR_OPEN_TIME_MS = 500 // Door open time in milliseconds
) ( 
    input wire clk,                   // 100MHz clock input
    input wire reset,                 // Active-high reset signal
    input wire [N-1:0] call_requests, // External Floor call requests
    input wire emergency_stop,        // Emergency stop signal
    input wire overload_detected,
    output reg [$clog2(N)-1:0] current_floor, // Current floor of the elevator
    output reg direction,             // Elevator direction: 1 = up, 0 = down
    output reg door_open,             // Door open signal
    output reg [2:0] system_status,    // Elevator system state indicator
    output reg overload_warning,          // Overload warning signal
    output [3:0]thousand,output[3:0] hundred, output [3:0]ten, output [3:0]one,
    output wire [6:0] seven_seg_out,    // Seven-segment display output for current floor visualization
    output wire [3:0] seven_seg_out_anode //Signal for switching between ones, tens, hundred, thousand place on seven segment
)
{
    // State Encoding
    localparam IDLE = 3'b000;          // Elevator is idle
    localparam MOVING_UP = 3'b001;     // Elevator moving up
    localparam MOVING_DOWN = 3'b010;   // Elevator moving down
    localparam EMERGENCY_HALT = 3'b011;// Emergency halt state
    localparam DOOR_OPEN = 3'b100;     // Door open state
    localparam OVERLOAD_HALT = 3'b101; // New state for overload condition

    // Internal registers
    reg [N-1:0] call_requests_internal;   // Internal copy of call requests
    reg [2:0] present_state, next_state; // FSM current and next states
    reg [$clog2(N)-1:0] max_request;     // Highest requested floor
    reg [$clog2(N)-1:0] min_request;    // Lowest requested floor

    // Door open time configuration
    `ifdef SIMULATION
        localparam CLK_FREQ_MHZ = 100;  // Clock frequency in MHz
        localparam SIM_DOOR_OPEN_TIME_MS = 0.05; // Shorter door open time for simulation
        localparam DOOR_OPEN_CYCLES = (SIM_DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000); // Door open cycles for simulation   
    `else
        // Calculating door open cycles based on time and clock frequency
        localparam CLK_FREQ_MHZ = 100;  // Clock frequency in MHz
        localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);   // Door open cycles for real implementation
    `endif

    reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;   // Counter for door open duration

    reg [$clog2(N)-1:0] current_floor_reg, current_floor_next=0;

    assign current_floor = current_floor_reg;

    // Update overload warning signal
    assign overload_warning = (overload_detected & ~emergency_stop) | (present_state == OVERLOAD_HALT);

    // FSM state transition
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            present_state <= IDLE;
            system_status <= IDLE;
            current_floor_reg <= 0;
            direction <= 1; // Ensure non-blocking assignment
            door_open <= 0;
            seven_seg_out_anode <= 3'b000;
        end else begin
            present_state <= next_state;
            system_status <= next_state;
            current_floor_reg <= current_floor_next;
            direction <= direction; // Ensure non-blocking assignment
            door_open <= door_open; // Ensure non-blocking assignment
            seven_seg_out_anode <= seven_seg_out_anode; // Ensure non-blocking assignment
        end
    end

    // FSM state transition logic with complete case statement coverage
    always@(*) begin
        next_state = present_state;
        current_floor_next = current_floor_reg;
        
        case (present_state)
            IDLE: begin
                if(overload_detected) begin
                    next_state = OVERLOAD_HALT;
                end else if(emergency_stop) begin
                    next_state = EMERGENCY_HALT;
                end else if(call_requests_internal != 0) begin
                    case (call_requests_internal[current_floor_reg])
                        call_requests_internal[current_floor_reg] != 0) begin
                            next_state = MOVING_UP;
                        end
                    end
                end
            end

            MOVING_UP: begin
                if(emergency_stop) begin
                    next_state = EMERGENCY_HALT;
                end else if(call_requests_internal[current_floor_reg + 1]) begin
                    current_floor_next = current_floor_reg + 1;
                    next_state = DOOR_OPEN;
                end else if(current_floor_reg >= max_request) begin
                    next_state = IDLE;
                end
                else begin
                    current_floor_next = current_floor_reg + 1;
                    next_state = MOVING_UP;
                end
            end

            MOVING_DOWN: begin
                if(emergency_stop) begin
                    next_state = EMERGENCY_HALT;
                end else if(call_requests_internal[current_floor_reg - 1]) begin
                    current_floor_next = current_floor_reg - 1;
                    next_state = DOOR_OPEN;
                end else if(current_floor_reg <= min_request) begin
                    next_state = IDLE;
                end
                else begin
                    current_floor_next = current_floor_reg - 1;
                    next_state = MOVING_DOWN;
                end
            end

            EMERGENCY_HALT: begin
                next_state = IDLE;
                current_floor_next = 0; // Optionally reset to ground floor
            end

            DOOR_OPEN: begin
                if(overload_detected) begin
                    next_state = OVERLOAD_HALT;
                end else if (door_open_counter == 0) begin
                    next_state = IDLE;
                end else begin
                    next_state = DOOR_OPEN;
                end
            end

            OVERLOAD_HALT: begin
                if(!overload_detected) begin
                    if(door_open) begin
                        next_state = DOOR_OPEN;
                    end else begin
                        next_state = IDLE;
                    end
                end
            end
        endcase
    end

    // Seven-segment display converter instantiation
    floor_to_seven_segment floor_display_converter (
        .clk(clk),
        .floor_display({$clog2(N)}{1'b0}),
        .seven_seg_out(seven_seg_out),
        .seven_seg_out_anode(seven_seg_out_anode),
        .thousand(thousand), .hundred(hundred),.ten(ten),.one(one)
    );

    // Update call requests and direction with non-blocking assignments
    always@(*) begin
        call_requests_internal = call_requests & ~call_requests_internal; // Ensure non-blocking assignment
        direction = (present_state == MOVING_UP) ? 1 : (present_state == MOVING_DOWN) ? 0 : 1; // Ensure non-blocking assignment
    end
}
