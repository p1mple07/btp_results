module elevator_control_system (#(
    parameter N = 8,
    parameter DOOR_OPEN_TIME_MS = 500
));

    reg [N-1:0] call_requests_internal;   // Internal copy of call requests
    reg [2:0] present_state, next_state;   // FSM current and next states
    reg [$clog2(N)-1:0] max_request;       // Highest requested floor
    reg [$clog2(N)-1:0] min_request;      // Lowest requested floor

    // Door open time configuration
    `ifdef SIMULATION
        localparam CLK_FREQ_MHZ = 100;
        localparam SIM_DOOR_OPEN_TIME_MS = 0.05;
        localparam DOOR_OPEN_CYCLES = (SIM_DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
`else
        // Real time calculation
        localparam CLK_FREQ_MHZ = 100;
        localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);
`endif

    reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;

    reg [$clog2(N)-1:0] current_floor_reg, current_floor_next = 0;

    assign current_floor = current_floor_reg;

    // Update overload warning signal
    assign overload_warning = (overload_detected == 1 && present_state == OVERLOAD_HALT);

    // FSM state transition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state <= IDLE;
            system_status <= IDLE;
            current_floor_reg <= 0;
        end else begin
            next_state = present_state;
            system_status <= next_state;
            current_floor_reg <= current_floor_next;
        end
    end

    // Calculate max_request and min_request
    always @(*) begin
        if (reset) begin
            max_request = 0;
            min_request = {$clog2(N){1'b1}};
        end else begin
            max_request = 0;
            min_request = {$clog2(N){1'b1}};
            for (integer i = 0; i < N; i = i + 1) begin
                if (call_requests_internal[i]) begin
                    if (i > max_request) max_request = i[$clog2(N)-1:0];
                    if (i < min_request) min_request = i[$clog2(N)-1:0];
                end
            end
        end
    end

    always @(posedge clk) begin
        // Reset door open counter when in DOOR_OPEN state
        if (present_state == DOOR_OPEN) begin
            door_open_counter <= DOOR_OPEN_CYCLES;
        end else begin
            door_open_counter <= DOOR_OPEN_CYCLES;
        end
    end

    // Seven-segment display converter
    floor_to_seven_segment floor_display_converter (
        .clk(clk),
        .floor_display({{8-($clog2(N)){1'b0}}}, current_floor_reg),
        .seven_seg_out(seven_seg_out),
        .seven_seg_out_anode(seven_seg_out_anode),
        .thousand(thousand), .hundred(hundred), .ten(ten), .one(one)
    );

endmodule
