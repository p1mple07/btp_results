rtl/event_scheduler.sv

// Module declaration
module event_scheduler (
    input clock,
    input reset,
    input add_event,
    input cancel_event,
    input [3:0] event_id,
    input [15:0] timestamp,
    input [3:0] priority_in,
    output [1] event_triggered,
    output [3:0] triggered_event_id,
    output error,
    output [15:0] current_time
);

// Instance of the actual implementation
event_scheduler dut (
    .clock(clock),
    .reset(reset),
    .add_event(add_event),
    .cancel_event(cancel_event),
    .event_id(event_id),
    .timestamp(timestamp),
    .priority_in(priority_in),
    .event_triggered(event_triggered),
    .triggered_event_id(triggered_event_id),
    .error(error),
    .current_time(current_time)
);

// State variables
reg [15:0] event_timestamps;
reg [3:0] event_priorities;
reg [1] event_valid;
wire [15:0] tmp_event_timestamps;
wire [3:0] tmp_event_priorities;
wire [1] tmp_event_valid;
wire [15:0] temp_current_time;

// Event selection logic
always begin
    // Increment time
    temp_current_time = current_time + (10 ns);
    
    // Scan for matching events
    triggered_event_id = -1;
    event_valid = 0;
    
    if (add_event) begin
        // Check if event is already scheduled
        if (event_timestamps[event_id] != -1) begin
            error = 1;
            // No action if event is already scheduled
        else begin
            // Store new event
            tmp_event_timestamps[event_id] = timestamp;
            tmp_event_priorities[event_id] = priority_in;
            tmp_event_valid[event_id] = 1;
        end
    end
    
    if (cancel_event) begin
        // Cancel event if valid
        if (event_valid[event_id]) begin
            tmp_event_valid[event_id] = 0;
        else begin
            error = 1;
        end
    end
    
    // Select the next event
    if (event_triggered) begin
        event_triggered = 0;
        triggered_event_id = -1;
        
        // Find all eligible events
        for (integer i = 0; i < 16; i++) {
            if (tmp_event_timestamps[i] <= temp_current_time &&
                tmp_event_valid[i] == 1) {
                // Select highest priority event
                if (tmp_event_priorities[i] > triggered_event_id) begin
                    triggered_event_id = tmp_event_priorities[i];
                    event_triggered = 1;
                end
            }
        }
    end
    
    // Update state
    event_timestamps = tmp_event_timestamps;
    event_priorities = tmp_event_priorities;
    event_valid = tmp_event_valid;
    current_time = temp_current_time;
end

// Test bench setup
initial begin
    // Event parameters
    integer num_tests = 5;
    integer max_time = 100 ns;
    
    // Event 0: Priority 0
    event_id[0] = 0;
    timestamp[0] = 0;
    priority_in[0] = 0;
    
    // Event 1: Priority 1
    event_id[1] = 1;
    timestamp[1] = 10 ns;
    priority_in[1] = 1;
    
    // Event 2: Priority 2
    event_id[2] = 2;
    timestamp[2] = 20 ns;
    priority_in[2] = 2;
    
    // Event 3: Priority 3
    event_id[3] = 3;
    timestamp[3] = 30 ns;
    priority_in[3] = 3;
    
    // Event 4: Priority 4
    event_id[4] = 4;
    timestamp[4] = 40 ns;
    priority_in[4] = 4;
    
    // Event 5: Priority 5
    event_id[5] = 5;
    timestamp[5] = 50 ns;
    priority_in[5] = 5;
    
    // Event 6: Priority 6
    event_id[6] = 6;
    timestamp[6] = 60 ns;
    priority_in[6] = 6;
    
    // Event 7: Priority 7
    event_id[7] = 7;
    timestamp[7] = 70 ns;
    priority_in[7] = 7;
    
    current_time = 0;
    
    // Wait until clock is stable
    repeat (num_tests) begin
        @posedge clock;
    end
    
    // Test cases
    foreach (i in 0[num_tests)) begin
        // Add event
        add_event = 1;
        event_id = i;
        timestamp = max_time;
        priority_in = i / 8;
        
        // Wait until clock is stable
        repeat (max_time / (10 ns)) begin
            @posedge clock;
        end
        
        // Assert event
        if (!event_triggered) begin
            $display("Test Case %0d Failed: Event %0d not triggered", i, i);
            error = 1;
        else begin
            $display("Test Case %0d Passed: Event %0d triggered at %0d ns", i, i, current_time);
        end
    end
end