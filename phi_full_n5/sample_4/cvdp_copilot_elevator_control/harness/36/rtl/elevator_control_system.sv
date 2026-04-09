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

    // State transition logic
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            present_state <= IDLE;
            system_status <= IDLE;
            current_floor_reg <= 0;
            door_open <= 0;
            door_open_counter <= DOOR_OPEN_CYCLES;
        end else begin
            // Non-blocking assignment for sequential logic
            present_state <= next_state;
            system_status <= next_state;
            current_floor_reg <= current_floor_next;
            door_open <= (present_state == OVERLOAD_HALT || present_state == DOOR_OPEN ? 1 : 0);
            door_open_counter <= (present_state == DOOR_OPEN ? DOOR_OPEN_CYCLES - door_open_counter : DOOR_OPEN_CYCLES);
        end
    end

    // FSM logic
    always@(*) begin
        if(reset) begin
            call_requests_internal = 0;
        end else begin
            call_requests_internal = call_requests; // Update requests without blocking
        end
    end

    // Call request management logic
    always@(*) begin
        if(present_state == IDLE || present_state == EMERGENCY_HALT) begin
            // Non-blocking assignment within sequential logic
            if(call_requests_internal[current_floor_reg] && current_floor_reg < max_request) begin
                call_requests_internal[current_floor_reg] = 0; // Clear served request
            end
        end
    end

    // FSM state transition logic
    always@(*) begin
        next_state = present_state;
        current_floor_next = current_floor_reg;
        
        case(present_state)
            IDLE: begin
                if(overload_detected) begin
                    next_state = OVERLOAD_HALT;
                end else if(emergency_stop) begin
                    next_state = EMERGENCY_HALT;
                end else if(call_requests_internal[current_floor_reg]) begin
                    current_floor_next = current_floor_reg + 1;
                    next_state = MOVING_UP; // Correctly prioritize the next floor
                end else if(current_floor_reg >= max_request) begin
                    next_state = IDLE; // Correctly idle after reaching the highest floor
                end
            end

            MOVING_UP: begin
                if(emergency_stop) begin
                    next_state = EMERGENCY_HALT;
                end else if(call_requests_internal[current_floor_reg + 1]) begin
                    current_floor_next = current_floor_reg + 1;
                    next_state = DOOR_OPEN;
                end else if(current_floor_reg >= max_request) begin
                    next_state = IDLE; // Correctly idle after reaching the highest floor
                end
            end

            MOVING_DOWN: begin
                if(emergency_stop) begin
                    next_state = EMERGENCY_HALT;
                end else if(call_requests_internal[current_floor_reg - 1]) begin
                    current_floor_next = current_floor_reg - 1;
                    next_state = DOOR_OPEN;
                end else if(current_floor_reg <= min_request) begin
                    next_state = IDLE; // Correctly idle after reaching the lowest floor
                end
            end

            EMERGENCY_HALT: begin
                next_state = IDLE; // Optionally reset to ground floor
            end

            DOOR_OPEN: begin
                next_state = (overload_detected ? OVERLOAD_HALT : IDLE); // Correctly handle door open during overload
                door_open <= (overload_detected ? 1 : 0);
            end

            OVERLOAD_HALT: begin
                door_open <= (overload_detected ? 1 : 0); // Correctly handle door open during overload
            end
        endcase
    end

    // Seven-segment display converter instantiation
    floor_to_seven_segment floor_display_converter (
        .clk(clk),
        .floor_display(current_floor_reg),
        .seven_seg_out(seven_seg_out),
        .seven_seg_out_anode(seven_seg_out_anode),
        .thousand(thousand), .hundred(hundred), .ten(ten), .one(one)
    );

    // Binary to BCD covertor for proper display
    Binary2BCD B1(.num(floor_display), .thousand(thousand), .hundred(hundred), .ten(ten), .one(one));

endmodule
