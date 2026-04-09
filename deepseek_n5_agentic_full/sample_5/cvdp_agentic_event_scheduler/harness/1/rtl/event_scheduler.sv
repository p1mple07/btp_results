module event_scheduler(

    // Event storage arrays
    reg [15:0] event_timestamps,
    reg [3:0] event_priorities,
    reg [3:0] event_valid,

    // Temporary copy arrays
    reg [15:0] tmp_event_timestamps,
    reg [3:0] tmp_event_priorities,
    reg [3:0] tmp_event_valid,

    // Current system time tracking
    reg [15:0] current_time,

    // Event control signals
    reg [3:0] event_id,
    reg [15:0] timestamp,
    reg [3:0] priority_in,

    // Event status signals
    reg event_triggered,
    reg [3:0] triggered_event_id,
    reg error
)

// State control variables
state_t current_state = 0;
state_t next_state = 0;

always_comb begin
    case(current_state)
    // State initialization
    0: current_state = 1;
    // Event storage initialization
    tmp_event_timestamps = 0;
    tmp_event_priorities = 0b0000;
    tmp_event_valid = 0;
    break;
    
    // Event storage update
    1: current_state = 2;
    current_time = current_time + (10 ns);
    break;
    
    // Event processing
    2: current_state = 3;
    if (add_event) begin
        if (valid_event(event_id)) {
            // Event collision
            error = 1;
        else begin
            tmp_event_timestamps[event_id] = timestamp;
            tmp_event_priorities[event_id] = priority_in;
            tmp_event_valid[event_id] = 1;
        }
    end
    if (cancel_event) begin
        if (!valid_event(event_id)) {
            error = 1;
        else begin
            tmp_event_valid[event_id] = 0;
        }
    end
    break;
    
    // Event selection and triggering
    3: current_state = 4;
    tmp_event_triggered = 0;
    triggered_event_id = -1;
    integer num_events = sum({event_valid});
    
    if (num_events > 0) begin
        for (integer i = 0; i < MAX_EVENTS; i++) {
            if ((tmp_event_valid[i] & 1) && (tmp_event_timestamps[i] <= current_time)) {
                tmp_event_triggered = 1;
                triggered_event_id = i;
                break;
            }
        }
    end
    
    if (tmp_event_triggered) begin
        event_triggered = 1;
        triggered_event_id = triggered_event_id;
        // Remove the event from storage
        tmp_event_valid[triggered_event_id] = 0;
    end
    break;
    
    // Final commit
    4: current_state = 0;
    // Write temporary arrays to main registers
    event_timestamps = tmp_event_timestamps;
    event_priorities = tmp_event_priorities;
    event_valid = tmp_event_valid;
    
    // Cleanup resources
    tmp_event_triggered = 0;
    tmp_event_timestamps = 0;
    tmp_event_priorities = 0;
    tmp_event_valid = 0;
    break;
    endcase
end

// Event validity check
function boolean valid_event(integer event_id) {
    if (event_id >= 0 && event_id < MAX_EVENTS) {
        return event_valid[event_id];
    }
    return false;
}

// Event priority comparison function
function integer compare_priorities(integer p1, integer p2) {
    if (p1 > p2) {
        return 1;
    } else if (p1 < p2) {
        return -1;
    }
    return 0;
}

// Event cleanup function
function void cleanup_event(integer event_id) {
    if (event_valid[event_id]) {
        event_priorities[event_id] = 0b0000;
        event_timestamps[event_id] = 0;
        event_valid[event_id] = 0;
    }
}

endmodule