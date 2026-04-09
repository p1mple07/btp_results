Module
module event_scheduler (
    input clock,
    input reset,
    input add_event,
    input cancel_event,
    input [3:0] event_id,
    input [15:0] timestamp,
    input [3:0] priority_in,
    output event_triggered,
    output [3:0] triggered_event_id,
    output error,
    output [15:0] current_time
);

// Event parameters
parameter MAX_EVENTS = 16;
type EVENT_T = integer[16];
type TIMESTAMP_T = integer[16];

// Internal state
reg [MAX_EVENTS-1:0] event_timestamps; // Current timestamp for each event
reg [MAX_EVENTS-1:0] event_priorities; // Priority for each event
reg [MAX_EVENTS-1:0] event_valid;     // Validity flag for each event
reg current_time;                   // Current system time

// Temporary storage for atomic updates
reg [MAX_EVENTS-1:0] tmp_event_timestamps;
reg [MAX_EVENTS-1:0] tmp_event_priorities;
reg [MAX_EVENTS-1:0] tmp_event_valid;
reg tmp_current_time;

// Event processing logic
always begin
    // Event addition
    if (add_event) begin
        if (event_valid[event_id]) begin
            error = 1;
            $display("Error: Event %d cannot be added as it is already active.", event_id);
        else begin
            // Store new event in temporary arrays
            tmp_event_timestamps[event_id] = timestamp;
            tmp_event_priorities[event_id] = priority_in;
            tmp_event_valid[event_id] = 1;
        end
        add_event = 0;
    end

    // Event cancellation
    if (cancel_event) begin
        if (!event_valid[event_id]) begin
            error = 1;
            $display("Error: Event %d cannot be canceled as it is not active.", event_id);
        else begin
            // Invalidate event in temporary arrays
            tmp_event_valid[event_id] = 0;
        end
        cancel_event = 0;
    end
end

// Update current_time and commit state
always begin
    if (reset) begin
        current_time = 0;
        tmp_current_time = 0;
        event_timestamps = (MAX_EVENTS-1:0) {0};
        event_priorities = (MAX_EVENTS-1:0) {0};
        event_valid = (MAX_EVENTS-1:0) {0};
        $display("System initialized. Current time: %0d ns", current_time);
        return;
    end

    // Increment time
    tmp_current_time = current_time + (10 * ((16'h10000000) / (10'h10)));
    current_time = tmp_current_time;

    // Event selection and triggering
    event_triggered = 0;
    triggered_event_id = (MAX_EVENTS-1:0) {0};

    if (add_event || cancel_event) begin
        // Find all eligible events
        for (event_id = 0; event_id < MAX_EVENTS; event_id++) {
            if (tmp_event_valid[event_id] & (tmp_event_timestamps[event_id] <= tmp_current_time)) begin
                // Select highest priority event
                if (event_priorities[event_id] > triggered_event_id[0]) begin
                    event_triggered = 1;
                    triggered_event_id[0] = event_id;
                end
            end
        }
    end

    // Commit state changes
    event_timestamps = tmp_event_timestamps;
    event_priorities = tmp_event_priorities;
    event_valid = tmp_event_valid;
    tmp_event_timestamps = (MAX_EVENTS-1:0) {0};
    tmp_event_priorities = (MAX_EVENTS-1:0) {0};
    tmp_event_valid = (MAX_EVENTS-1:0) {0};
end

// Event status reporting
always begin
    if (event_triggered) begin
        $display("Event %d triggered at time %0d ns", triggered_event_id[0], current_time);
    end
end

endmodule