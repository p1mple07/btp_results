Module implementation version: 1.0

module event_scheduler (
    parameter integer MAX_EVENTS = 16,
    parameter integer TIMESTAMP_WIDTH = 16,
    parameter integer PRIORITY_WIDTH = 4,
    parameter integer TIME_INCREMENT = 10
)

    // Internal state variables
    reg [
        TIMESTAMP_WIDTH-1:0
    ] current_time;
    
    reg [
        MAX_EVENTS-1:0
    ] event_timestamps;
    
    reg [
        MAX_EVENTS-1:0
    ] event_priorities;
    
    reg [
        MAX_EVENTS-1:0
    ] event_valid;
    
    // Temporary state copies for atomic updates
    reg [
        TIMESTAMP_WIDTH-1:0
    ] tmp_event_timestamps;
    
    reg [
        PRIORITY_WIDTH-1:0
    ] tmp_event_priorities;
    
    reg [
        MAX_EVENTS-1:0
    ] tmp_event_valid;
    
    // Event processing pipeline stages
    always @posedge clk begin
        // Time increment and wrap
        current_time = current_time + TIME_INCREMENT;
        
        // Event selection and processing
        // 1. Scan for eligible events
        integer selected_event_id = -1;
        integer max_priority = -1;
        integer num eligibles = 0;
        
        for (integer i = 0; i < MAX_EVENTS; i++) {
            if (tmp_event_valid[i]) {
                if (!event_timestamps[i]) {
                    continue;
                }
                
                // Update eligibility status
                tmp_event_valid[i] = 0;
                
                if (event_timestamps[i] <= current_time) {
                    num eligibles++;
                    selected_event_id = -1;
                    max_priority = -1;
                    
                    // Track highest priority among eligibles
                    if (event_priorities[i] > max_priority) {
                        max_priority = event_priorities[i];
                        selected_event_id = i;
                    }
                }
            }
        }
        
        // Handle multiple eligible events by selecting highest priority
        if (selected_event_id != -1) {
            // Trigger the event
            event_triggered = 1;
            triggered_event_id = selected_event_id;
            
            // Deactivate the selected event
            event_valid[selected_event_id] = 0;
            
            // Atomic write back to main registers
            event_timestamps[selected_event_id] = tmp_event_timestamps[selected_event_id];
            event_priorities[selected_event_id] = tmp_event_priorities[selected_event_id];
            event_valid[selected_event_id] = tmp_event_valid[selected_event_id];
        } else {
            // No eligible event found
            event_triggered = 0;
        }
    end

    // State commit for final register writes
    always @posedge clk begin
        // Write back temporary changes
        event_timestamps = tmp_event_timestamps;
        event_priorities = tmp_event_priorities;
        event_valid = tmp_event_valid;
    end

    // Interface definitions
    input
        clk,
        reset,
        add_event,
        cancel_event,
        event_id,
        timestamp,
        priority_in
    ;
    
    output
        event_triggered,
        triggered_event_id,
        error
    ;
    
    // Initializations and tests
    reg [MAX_EVENTS-1:0] event_valid_initial;
    
    initial begin
        // Initialize all event states to default (invalid)
        fill(event_valid_initial, 8'h1, MAX_EVENTS);
        
        // Event initialization
        event_timestamps = 0;
        event_priorities = 0;
        event_valid = event_valid_initial;
        
        // Test case setup
        #50;
        if (add_event) begin
            add_event = 0;
            #50;
        end
    end

    // Signal mappings
    wire (
        .clk(clk),
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
    ) dut (

        .event_timestamps(event_timestamps),
        .event_priorities(event_priorities),
        .event_valid(event_valid),
        .tmp_event_timestamps(tmp_event_timestamps),
        .tmp_event_priorities(tmp_event_priorities),
        .tmp_event_valid(tmp_event_valid)
    );

endmodule