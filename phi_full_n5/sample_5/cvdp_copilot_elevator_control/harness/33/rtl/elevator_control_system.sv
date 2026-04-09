module elevator_control_system #(
    parameter N = 8,
    parameter DOOR_OPEN_TIME_MS = 500
) (
    input wire clk,
    input wire reset,
    input wire [N-1:0] call_requests,
    input wire emergency_stop,
    input wire overload_detected,
    output reg [$clog2(N)-1:0] current_floor,
    output reg [2:0] system_status,
    output reg [3:0] thousand,
    output reg [3:0] hundred,
    output reg [3:0] ten,
    output reg [3:0] one,
    output wire [6:0] seven_seg_out,
    output reg [3:0] seven_seg_out_anode
) {
    // State Encoding
    localparam IDLE = 3'b000;
    localparam MOVING_UP = 3'b001;
    localparam MOVING_DOWN = 3'b010;
    localparam EMERGENCY_HALT = 3'b011;
    localparam DOOR_OPEN = 3'b100;
    localparam OVERLOAD_HALT = 3'b101;

    // Internal registers
    reg [N-1:0] call_requests_internal;
    reg [2:0] present_state, next_state;
    reg [$clog2(N)-1:0] max_request, min_request;

    // Door open time configuration
    `ifdef SIMULATION
        localparam CLK_FREQ_MHZ = 100;
        localparam SIM_DOOR_OPEN_TIME_MS = 0.05;
        localparam DOOR_OPEN_CYCLES = (SIM_DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
    `else
        localparam CLK_FREQ_MHZ = 100;
        localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
    `endif

    reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;

    reg [$clog2(N)-1:0] current_floor_reg, current_floor_next = 0;

    assign current_floor = current_floor_reg;

    // Door open control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state <= IDLE;
            system_status <= IDLE;
            current_floor_reg <= 0;
            door_open_counter <= DOOR_OPEN_CYCLES;
            door_open <= 0;
        end else begin
            present_state <= next_state;
            system_status <= next_state;
            current_floor_reg <= current_floor_next;
            door_open <= (door_open_counter == 0 ? 1 : 0); // Non-blocking assignment
            door_open_counter <= DOOR_OPEN_CYCLES; // Non-blocking assignment
        end
    end

    // FSM state transition
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            max_request <= 0;
            min_request <= N-1;
        end else begin
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

    always@(*)begin
        next_state = present_state;
        current_floor_next = current_floor_reg;
        
        case(present_state)
            IDLE: begin
                if(overload_detected) next_state = OVERLOAD_HALT;
                else if(emergency_stop) next_state = EMERGENCY_HALT;
                else if(call_requests_internal != 0) begin
                    if(max_request > current_floor_reg) next_state = MOVING_UP;
                    if(min_request < current_floor_reg) next_state = MOVING_DOWN;
                end
            end
            // ... (rest of the states)
        end
    endcase

    // ... (rest of the module)
}
