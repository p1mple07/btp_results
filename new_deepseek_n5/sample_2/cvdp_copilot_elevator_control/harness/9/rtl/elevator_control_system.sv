// State Encoding
localparam IDLE = 3'b000;          // Elevator is idle
localparam MOVING_UP = 3'b001;     // Elevator moving up
localparam MOVING_DOWN = 3'b010;   // Elevator moving down
localparam EMERGENCY_HALT = 3'b011;// Emergency halt state
localparam OVERLOAD_HALT = 3'b100;// Overload halt state
localparam DOOR_OPEN = 3'b101;// Door open state

// Internal registers
reg [N-1:0] call_requests_internal;   // Internal copy of call requests
reg [2:0] present_state, next_state; // FSM current and next states
reg [$clog2(N)-1:0] max_request;     // Highest requested floor
reg [$clog2(N)-1:0] min_request;    // Lowest requested floor
reg [2:0] overload_counter;          // Overload counter

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

// FSM state transition
always@(posedge clk or posedge reset) begin
    if(reset)begin
        present_state <= IDLE;
        system_status <= IDLE;
        current_floor_reg <= 0;
        max_request <= 0;
        min_request <= N-1;
        overload_counter <= 0;
        overload_warning <= 0;
    end else begin
        present_state <= next_state;
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
        
        // Overload detection logic
        if (overload_detected) begin
            next_state <= OVERLOAD_HALT;
            overload_warning <= 1;
        end else begin
            if (reset) begin
                next_state <= IDLE;
                current_floor_next <= 0;
            end else begin
                present_state <= next_state;
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
                
                // Door open control logic
                if (reset) begin
                    door_open_counter <= 0;
                    door_open <= 0;
                end else begin
                    if (present_state == DOOR_OPEN) begin
                        if (door_open_counter > 0) begin
                            door_open <= 1;
                            door_open_counter <= door_open_counter - 1;
                        end else begin
                            door_open <= 0;
                            next_state <= IDLE;
                        end
                    end else begin
                        door_open <= 0;
                        door_open_counter <= DOOR_OPEN_CYCLES;
                    end
                end
                
                // Call request management
                if(reset) begin
                    call_requests_internal = 0;
                end else begin
                    if(call_requests_internal[current_floor_reg])begin
                        call_requests_internal[current_floor_reg] = 0;      // Clear served request
                    end
                    call_requests_internal = call_requests_internal | call_requests;    // Update requests
                end
            end
        end
    endcase
end

// Door open control logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        door_open_counter <= 0;
        door_open <= 0;
    end else begin
        if (present_state == DOOR_OPEN) begin
            if (door_open_counter > 0) begin
                door_open <= 1;
                door_open_counter <= door_open_counter - 1;
            end else begin
                door_open <= 0;
                next_state <= IDLE;
            end
        end else begin
            door_open <= 0;
            door_open_counter <= DOOR_OPEN_CYCLES;
        end
    end
end

// Call request management
always@(*)begin
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
always@(*)begin
    if(reset) begin
        direction = 1;
    end else begin
        if(present_state == MOVING_UP)begin
            direction = 1;
        end else if (present_state == MOVING_DOWN) begin
            direction = 0;
        end else begin
            direction = 1;
        end
    end
end

// Seven-segment display converter instantiation
floor_to_seven_segment #(.N(8)) floor_display_converter (
    .floor_display(current_floor_reg),
    .seven_seg_out(seven_seg_out)
);

endmodule