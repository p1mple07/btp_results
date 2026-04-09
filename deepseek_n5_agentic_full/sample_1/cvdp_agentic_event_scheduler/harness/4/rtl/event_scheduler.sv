module event_scheduler(
    input clocks,
    input reset,
    input add_event,
    input cancel_event,
    input [3:0] event_id,
    input [15:0] timestamp,
    input [3:0] priority_in,
    input modify_event,
    input [15:0] new_timestamp,
    input [3:0] new_priority,
    input recurring_event,
    input [15:0] recurring_interval,
    output reg event_triggered,
    output reg [3:0] triggered_event_id,
    output reg error,
    output reg [15:0] current_time,
    output reg [15:0] log_event_time,
    output reg [3:0] log_event_id
);

    // New local registers for event modification/recurring
    reg [15:0] event_timestamps_local [15:0];
    reg [3:0] event_priorities_local [15:0];
    reg [15:0] event_valid_local [15:0];
    reg bool pending_modify;
    reg bool pending_recur;

    // Event modification counters
    reg int mod_counter = 0;
    reg int recur_counter = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_time <= 0;
            event_triggered <= 0;
            triggered_event_id <= 0;
            error <= 0;
            
            // Initialize new event registers
            fill(event_timestamps_local, 0);
            fill(event_priorities_local, 0);
            fill(event_valid_local, 0);
            
            pending_modify = false;
            pending_recur = false;
        end else begin
            // First handle new events
            if (add_event) begin
                if (event_id >= 0 && event_id < 16) begin
                    if (event_valid_local[event_id]) begin
                        error <= 1; 
                    end else begin
                        // Add new event
                        event_timestamps_local[event_id] = new_timestamp;
                        event_priorities_local[event_id] = new_priority;
                        event_valid_local[event_id] = 1;
                        error <= 0;
                    end
                end else begin
                    error <= 1; 
                end
            end

            if (cancel_event) begin
                if (event_id >= 0 && event_id < 16) begin
                    if (event_valid_local[event_id]) begin
                        event_valid_local[event_id] = 0;
                        error <= 0;
                    end else begin
                        error <= 1; 
                    end
                end else begin
                    error <= 1; 
                end
            end

            // Handle modifications
            if (modify_event) begin
                if (pending_modify) begin
                    // Rollback previous modification
                    pending_modify = false;
                    error <= 0;
                end else begin
                    if (event_id >= 0 && event_id < 16) begin
                        if (event_valid_local[event_id]) begin
                            event_timestamps_local[event_id] = new_timestamp;
                            event_priorities_local[event_id] = new_priority;
                            pending_modify = true;
                        else begin
                            error <= 1;
                        end
                    end else begin
                        error <= 1;
                    end
                end
            end

            // Handle recurring events
            if (recurring_event) begin
                if (pending_recur) begin
                    // Rollback previous recurrence
                    pending_recur = false;
                    error <= 0;
                end else begin
                    if (event_id >= 0 && event_id < 16 && event_valid_local[event_id]) begin
                        // Update timestamp by adding interval
                        event_timestamps_local[event_id] += recurring_interval;
                        pending_recur = true;
                    else begin
                        error <= 1;
                    end
                end
            end

            // Proceed with normal event selection
            if (add_event || cancel_event || modify_event || recurring_event) begin
                // Check if event is ready to trigger
                if (new_timestamp >= current_time + 10) begin
                    if (event_id >= 0 && event_id < 16) begin
                        if (event_valid_local[event_id]) begin
                            // Select eligible event with highest priority
                            chosen_event = -1;
                            for (j = 0; j < 16; j = j + 1) begin
                                if (event_valid_local[j] && (event_timestamps_local[j] <= current_time + 10)) begin
                                    if ((chosen_event == -1) || (event_priorities_local[j] > event_priorities_local[chosen_event])) begin
                                        chosen_event = j;
                                    end
                                end
                            end

                            if (chosen_event != -1) begin
                                event_triggered <= 1;
                                triggered_event_id <= chosen_event;
                                tmp_event_valid[chosen_event] <= 0;
                            end else begin
                                event_triggered <= 0;
                            end

                            // Log event
                            log_event_time <= current_time + 10;
                            log_event_id <= event_id;
                        end else begin
                            error <= 1;
                        end
                    end
                end
            end

            // Update current_time and commit changes
            current_time <= tmp_current_time;
            // Update all temporary state to global registers
            foreach (j in 0..15) begin
                event_timestamps[j] <= event_timestamps_local[j];
                event_priorities[j] <= event_priorities_local[j];
                event_valid[j] <= event_valid_local[j];
            end
        end
    end

    reg [15:0] tmp_event_timestamps_local [15:0];
    reg [3:0] tmp_event_priorities_local [15:0];
    reg [15:0] tmp_event_valid_local [15:0];
    integer i, j;

    // ... rest of the original implementation ...