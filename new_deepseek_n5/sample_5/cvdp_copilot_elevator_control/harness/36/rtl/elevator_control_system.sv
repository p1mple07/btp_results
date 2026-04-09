module implements an FSM-based elevator control system capable of managing multiple floors,
 * handling call requests, and responding to emergency stops. The elevator transitions between 
 * five main states: Idle, Moving Up, Moving Down, Emergency Halt, and Door Open. It prioritizes floor requests 
 * based on direction, moving to the highest or lowest requested floor depending on the current direction.
*/

module elevator_control_system #(
    parameter N = 8, //Number of floors
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
    output reg [3:0] system_status,    // Elevator system state indicator
    output wire [3:0] thousand,        // Thousands place indicator
    output wire [3:0] hundred,         // Hundreds place indicator
    output wire [3:0] ten,             // Tens place indicator
    output wire [3:0] one,             // Ones place indicator
    output wire seven_seg_out,        // Seven-segment display output for current floor visualization
    output wire [3:0] seven_seg_out_anode // Signal for switching between ones, tens, hundred, thousand place on seven segment
);

// State Encoding
localparam IDLE = 3'b000;          // Elevator is idle
localparam MOVING_UP = 3'b001;     // Elevator moving up
localparam MOVING_DOWN = 3'b010;   // Elevator moving down
localparam EMERGENCY_HALT = 3'b011;// Emergency halt state
localparam DOOR_OPEN = 3'b100;     // Door open state
localparam OVERLOAD_HALT = 3'b101; // New state for overload condition

// Internal registers
reg [19:0] shift;
reg [2:0] current_floor_reg;
reg [$clog2(N)-1:0] max_request;
reg [$clog2(N)-1:0] min_request;

// Door open time configuration
`ifdef SIMULATION
    localparam CLK_FREQ_MHZ = 100;  // Clock frequency in MHz
    localparam SIM_DOOR_OPEN_TIME_MS = 0.05; // Shorter door open time for simulation
    localparam DOOR_OPEN_CYCLES = (SIM_DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000); // Door open cycles for simulation   
`else
    localparam CLK_FREQ_MHZ = 100;  // Clock frequency in MHz
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);   // Door open cycles for real implementation
`endif

reg [$clog2(N)-1:0] door_open_counter;   // Counter for door open duration

// FSM state transition
always @(posedge clk or posedge reset) begin
    if(reset) begin
        current_floor_reg <= 0;
        system_status <= IDLE;
        door_open <= 0;
        door_open_counter <= DOOR_OPEN_CYCLES;
    end else begin
        case(current_floor_reg)
            IDLE: begin
                if(overload_detected) door_open <= 1;
                else if(emergency_stop) door_open <= 1;
                else if(call_requests_internal != 0) begin
                    if(max_request > current_floor_reg) current_floor_reg <= max_request;
                    else if(min_request < current_floor_reg) current_floor_reg <= min_request;
                    else current_floor_reg <= current_floor_reg + 1;
                end
                system_status <= next_state;
            end

            MOVING_UP: begin
                if(emergency_stop) door_open <= 1;
                else if(call_requests_internal[current_floor_reg+1]) begin
                    current_floor_reg <= current_floor_reg + 1;
                    door_open <= 1;
                end else if(current_floor_reg >= max_request) begin
                    current_floor_reg <= max_request;
                    system_status <= IDLE;
                end else begin
                    current_floor_reg <= current_floor_reg + 1;
                    system_status <= MOVING_UP;
                end
            end

            MOVING_DOWN: begin
                if(emergency_stop) door_open <= 1;
                else if(call_requests_internal[current_floor_reg-1]) begin
                    current_floor_reg <= current_floor_reg - 1;
                    door_open <= 1;
                end else if(current_floor_reg <= min_request) begin
                    current_floor_reg <= min_request;
                    system_status <= IDLE;
                end else begin
                    current_floor_reg <= current_floor_reg - 1;
                    system_status <= MOVING_DOWN;
                end
            end

            EMERGENCY_HALT: begin
                if(!emergency_stop) begin
                    next_state = IDLE;
                    current_floor_reg <= 0;
                end
            end

            DOOR_OPEN: begin
                if(overload_detected) next_state = OVERLOAD_HALT;
                else if(door_open_counter > 0) next_state = IDLE;
                else next_state = DOOR_OPEN;
            end

            OVERLOAD_HALT: begin
                if(!overload_detected) begin
                    next_state = DOOR_OPEN;
                end else begin
                    next_state = IDLE;
                end
            end
        endcase
    end
end

// Door open control logic
always @(posedge clk) begin
    if(reset) door_open <= 0;
    else if(current_floor == OVERLOAD_HALT) begin
        door_open <= 1;
    end else if(current_floor == DOOR_OPEN) begin
        if(door_open_counter > 0) door_open <= 1 else door_open <= 0;
    end else door_open <= 0;
end

// Floor to seven-segment display converter
floor_to_seven_segment (
    .clk(clk),
    .floor_display({{8-($clog2(N)){1'b1}},current_floor_reg}),
    .seven_seg_out(seven_seg_out),
    .seven_seg_out_anode(seven_seg_out_anode),
    .thousand(thousand), .hundred(hundred), .ten(ten), .one(one)
);

endmodule