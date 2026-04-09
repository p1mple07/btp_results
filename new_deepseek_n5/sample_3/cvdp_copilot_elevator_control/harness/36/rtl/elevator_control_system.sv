module elevator_control_system #(
    parameter N = 8, //Number of floors
    parameter DOOR_OPEN_TIME_MS = 500 //Door open time in milliseconds
) ( 
    input wire clk,                   // 100MHz clock input
    input wire reset,                 // Active-high reset signal
    input wire [N-1:0] call_requests, // External Floor call requests
    input wire emergency_stop,        // Emergency stop signal
    input wire overload_detected,      // Overload condition signal
    output wire [3:0] system_status,    // Elevator system state indicator
    output overload_warning,          // Overload warning signal
    output [3:0]thousand, hundred, ten, one,
    output wire [6:0] seven_seg_out,    // Seven-segment display output for current floor visualization
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
integer i;
    
always @(posedge clk or posedge reset) begin
    if(reset)begin
        shift[19:8] =0;
        shift[7:0]=0;
        system_status <= IDLE;
        current_floor_reg <=0;
    end else begin
        shift[19:8] = shift <<1;
        shift[7:0]=num;
        
        for(i=0;i<8;i=i+1)
        begin
            if(shift[11:8]>=5)
                shift[11:8] = shift[11:8] +3;
            if(shift[15:12]>=5)
                    shift[15:12] = shift[15:12] +3; 
            if(shift[19:16]>=5)
                shift[19:16] = shift[19:16] +3;
        end
        
        hundred=shift[19:16];
        ten=shift[15:12];
        one=shift[11:8];
        thousand=4'b0000;
        
        if(shift[19:16]>=5)
            thousand=4'b0001;
        else if(shift[15:12]>=5)
            thousand=4'b0010;
        else if(shift[11:8]>=5)
            thousand=4'b0011;
        else
            thousand=4'b0000;
    end
end

always@(*) begin
    if(reset)begin
        seven_seg_out <= {{8-($clog2(N){1'b1})},{1'b1[27:24]},{1'b1[26:23]},{1'b1[25:22]},{1'b1[24:21]},{1'b1[23:20]},{1'b1[22:19]},{1'b1[19:16]},{1'b1[16:13]},{1'b1[13:10]},{1'b1[10:7]},{1'b1[7:4]},{1'b1[4:1]},{1'b1[1:0]}}; 
        seven_seg_out_anode <= {{8-($clog2(N){1'b1})},{1'b1[27:24]},{1'b1[26:23]},{1'b1[25:22]},{1'b1[24:21]},{1'b1[23:20]},{1'b1[22:19]},{1'b1[19:16]},{1'b1[16:13]},{1'b1[13:10]},{1'b1[10:7]},{1'b1[7:4]},{1'b1[4:1]},{1'b1[1:0]}}; 
        current_floor = current_floor_reg;
    end else begin
        if(reset)begin
            current_floor <=0;
        end else begin
            if(current_floor == OVERLOAD_HALT) begin
                system_status <= OVERLOAD_HALT;
            end else if(current_floor == DOOR_OPEN) begin
                if(door_open <=0) begin
                    system_status <= IDLE;
                end else begin
                    current_floor_next = current_floor +1;
                    next_state = MOVING_UP;
                end
            end else begin
                current_floor_next = current_floor +1;
                next_state = MOVING_UP;
            end
        end
    end
end

always@(*)begin
    if(reset)begin
        door_open <=0;
    end else begin
        if(current_floor == OVERLOAD_HALT)begin
            door_open <=1;
        end else if(current_floor == DOOR_OPEN)begin
            if(door_open <=0)begin
                door_open <=0;
            end else begin
                door_open <=1;
            end
        end else begin
            door_open <=0;
        end
    end
end

always@(*)begin
    if(reset)begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end else if(current_floor == DOOR_OPEN)begin
        if(door_open_counter >0)begin
            door_open_counter <= door_open_counter -1;
        end else begin
            door_open_counter <= DOOR_OPEN_CYCLES;
        end
    end else begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end
end

always@(*)begin
    if(reset)begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end else if(current_floor == DOOR_OPEN)begin
        if(door_open_counter >0)begin
            door_open_counter <= door_open_counter -1;
        end else begin
            door_open_counter <= DOOR_OPEN_CYCLES;
        end
    end else begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end
end

always@(*)begin
    if(reset)begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end else if(current_floor == DOOR_OPEN)begin
        if(door_open_counter >0)begin
            door_open_counter <= door_open_counter -1;
        end else begin
            door_open_counter <= DOOR_OPEN_CYCLES;
        end
    end else begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end
end

always@(*)begin
    if(reset)begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end else if(current_floor == DOOR_OPEN)begin
        if(door_open_counter >0)begin
            door_open_counter <= door_open_counter -1;
        end else begin
            door_open_counter <= DOOR_OPEN_CYCLES;
        end
    end else begin
        door_open_counter <= DOOR_OPEN_CYCLES;
    end
end

// Call request management
always@(*)begin
    if(reset)begin
        call_requests_internal = 0;
    end else begin
        if(call_requests_internal[current_floor_reg])begin
            call_requests_internal[current_floor_reg] = 0;
        end
        call_requests_internal = call_requests_internal | call_requests;
    end
end

// Direction control logic
always@(*)begin
    if(reset)begin
        direction = 1;
    end else begin
        if(current_floor == MOVING_UP)begin
            direction = 1;
        end else if(current_floor == MOVING_DOWN)begin
            direction = 0;
        end else begin
            direction = 1;
        end
    end
end

// Seven-segment display converter
floor_to_seven_segment floor_display_converter (
    .clk(clk),
    .floor_display({{8-($clog2(N){1'b1})},{1'b1[27:24]},{1'b1[26:23]},{1'b1[25:22]},{1'b1[24:21]},{1'b1[23:20]},{1'b1[22:19]},{1'b1[19:16]},{1'b1[16:13]},{1'b1[13:10]},{1'b1[10:7]},{1'b1[7:4]},{1'b1[4:1]},{1'b1[1:0]}} ),
    .seven_seg_out(seven_seg_out),
    .seven_seg_out_anode(seven_seg_out_anode),
    .thousand(thousand),
    .hundred(hundred),
    .ten(ten),
    .one(one)
);

endmodule