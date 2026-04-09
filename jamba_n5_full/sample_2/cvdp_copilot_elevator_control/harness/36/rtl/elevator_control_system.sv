module elevator_control_system #(
    parameter N = 8,
    parameter DOOR_OPEN_TIME_MS = 500
) (
    input wire clk,
    input wire reset,
    input wire [N-1:0] call_requests,
    input wire emergency_stop,
    input wire overload_detected,
    output wire [$clog2(N)-1:0] current_floor,
    output reg direction,
    output reg door_open,
    output reg [2:0] system_status,
    output wire [6:0] seven_seg_out,
    output wire [3:0] seven_seg_out_anode
);

    // Internal registers
    reg [N-1:0] call_requests_internal;   // Internal copy of call requests
    reg [2:0] present_state, next_state;   // FSM current and next states
    reg [$clog2(N)-1:0] max_request;      // Highest requested floor
    reg [$clog2(N)-1:0] min_request;      // Lowest requested floor

    // Door open time configuration
    localparam CLK_FREQ_MHZ = 100;
    localparam SIM_DOOR_OPEN_TIME_MS = 0.05;
    localparam DOOR_OPEN_CYCLES = (DOOR_OPEN_TIME_MS * CLK_FREQ_MHZ * 1000);

    reg [$clog2(DOOR_OPEN_CYCLES)-1:0] door_open_counter;

    reg [$clog2(N)-1:0] current_floor_reg, current_floor_next;

    // Configure seven-segment display
    floor_to_seven_segment floor_display_converter (
        .clk(clk),
        .floor_display({{8-($clog2(N)){1'b0}}}, current_floor_reg),
        .seven_seg_out(seven_seg_out),
        .seven_seg_out_anode(seven_seg_out_anode),
        .thousand(thousand), .hundred(hundred), .ten(ten), .one(one)
    );

    // FSM initial state
    initial begin
        present_state = IDLE;
        system_status = IDLE;
        current_floor_reg = 0;
    end

    // Always block: react to positive edge of clock or reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state <= IDLE;
            system_status <= IDLE;
            current_floor_reg <= 0;
        end else begin
            present_state <= next_state;
            system_status <= next_state;
            current_floor_reg <= current_floor_next;
        end
    end

    // Max request calculation
    always @(current_floor_reg) begin
        max_request = 0;
        min_request = $clog2(N){1'b1};
        for (integer i = 0; i < N; i = i + 1) begin
            if (call_requests_internal[i]) begin
                if (i > max_request) 
                    max_request = i[$clog2(N)-1:0];
                if (i < min_request)  
                    min_request = i[$clog2(N)-1:0];
            end
        end
    end

    // Door open control
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            door_open <= 0;
        end else begin
            if (present_state == OVERLOAD_HALT) begin
                door_open <= 1;
            end else if (present_state == DOOR_OPEN) begin
                if (door_open_counter == 0) begin
                    next_state = IDLE;
                end else begin
                    next_state = DOOR_OPEN;
                end
            end else begin
                next_state = DOOR_OPEN;
            end
        end
    end

    // Seven‑segment output conversion
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seven_seg_out <= 8'b1111111;
            seven_seg_out_anode <= 4'b1110;
        end else begin
            // Convert floor value to BCD
            B1 (.num(current_floor), .thousand(thousand), .hundred(hundred), .ten(ten), .one(one));
            seven_seg_out <= sseg_temp;
            seven_seg_out_anode <= an_temp;
        end
    end

endmodule
