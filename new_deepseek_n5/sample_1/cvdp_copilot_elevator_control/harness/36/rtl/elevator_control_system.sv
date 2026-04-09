module elevator_control_system (
    input [7:0] call_requests, 
    input emergency_stop, 
    input overload_detected,
    output wire [3:0]thousand, output [3:0] hundred, output [3:0] ten, output [3:0] one,
    output [6:0] seven_seg_out, output [3:0] seven_seg_out_anode
);

// State Encoding
localparam IDLE = 3'b000;
localparam MOVING_UP = 3'b001;
localparam MOVING_DOWN = 3'b010;
localparam EMERGENCY_HALT = 3'b011;
localparam DOOR_OPEN = 3'b100;
localparam OVERLOAD_HALT = 3'b101;

// Internal registers
reg [19:0] shift;
reg [2:0] current_floor;
reg [2:0] next_state;
reg [2:0] max_request;
reg [2:0] min_request;
reg [2:0] door_open_counter;

// Door open time configuration
localparam CLK_FREQ_MHZ = 100;
localparam DOOR_OPEN_CYCLES = (DOOR_OPEN / CLK_FREQ_MHZ * 1000);

// FSM state transition
always @(posedge clock or posedge reset) begin
    if(reset) begin
        shift[19:8] = 0;
        shift[7:0] = 0;
        current_floor = 0;
        max_request = 0;
        min_request = {$clog2(N){1'b1}};        
    end else begin
        if(reset) begin
            max_request = 0;
            min_request = {$clog2(N){1'b1}};        
        end else begin
            // Calculate max and min requests based on direction
            max_request = 0;
            min_request = {$clog2(N){1'b1}};        
            for (integer i = 0; i < N; i = i + 1) begin
                if (call_requests_internal[i]) begin
                    if (i > max_request) max_request = i;
                    if (i < min_request) min_request = i;
                end
            end
        end
    end end

    // Update max_request and min_request based on active requests
    max_request = 0;
    min_request = {$clog2(N){1'b1}};        
    for (integer i = 0; i < N; i = i + 1) begin
        if (call_requests_internal[i]) begin
            if (i > max_request) max_request = i;
            if (i < min_request) min_request = i;
        end
    end

    // Calculate max_request and min_request based on active requests
    max_request = 0;
    min_request = {$clog2(N){1'b1}};        
    for (integer i = 0; i < N; i = i + 1) begin
        if (call_requests_internal[i]) begin
            if (i > max_request) max_request = i;
            if (i < min_request) min_request = i;
        end
    end

    // Door open time configuration
    localparam CLK_FREQ_MHZ = 100;
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN / CLK_FREQ_MHZ * 1000);

    // Door open time configuration
    localparam CLK_FREQ_MHZ = 100;
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN / CLK_FREQ_MHZ * 1000);

    // Door open time configuration
    localparam CLK_FREQ_MHZ = 100;
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN / CLK_FREQ_MHZ * 1000);

    // Door open time configuration
    localparam CLK_FREQ_MHZ = 100;
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN / CLK_FREQ_MHZ * 1000);

    // Door open time configuration
    localparam CLK_FREQ_MHZ = 100;
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN / CLK_FREQ_MHZ * 1000);
endmodule