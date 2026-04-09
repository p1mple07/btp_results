module event_scheduler(
    input clocksignal(clk),
    input reset,
    input add_event,
    input cancel_event,
    input [3:0] event_id,
    input [15:0] timestamp,
    input [3:0] priority_in,
    input [3:0] modify_event,
    input [15:0] new_timestamp,
    input [3:0] new_priority,
    input recurring_event,
    input [15:0] recurring_interval,
    output reg event_triggered,
    output reg [3:0] triggered_event_id,
    output reg error,
    output reg [15:0] current_time,
    output reg [3:0] log_event_time,
    output reg [3:0] log_event_id
);

    // Internal state management
    reg [15:0] event_timestamps [15:0];
    reg [3:0] event_priorities [15:0];
    reg [15:0] event_valid [15:0];
    reg [15:0] tmp_event_timestamps [15:0];
    reg [3:0]  tmp_event_priorities [15:0];
    reg        tmp_event_valid [15:0];
    int cnt = 0;

    // Event modification logic
    reg [3:0] mod_event_id = -1;
    reg [15:0] mod_timestamp = 0;
    reg [3:0]  mod_priority = -1;
    reg [15:0] mod validity = 0;

    // Error handling
    reg error_flag = 0;

    // Main clock cycle processing
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_time <= 0;
            event_triggered <= 0;
            triggered_event_id <= 0;
            error <= 0;
            for (i = 0; i < 16; i = i + 1) begin
                event_timestamps[i] <= 0;
                event_priorities[i] <= 0;
                event_valid[i] <= 0;
            end
        else begin
            // Apply modifications first
            if (modify_event) begin
                if (event_valid[mod_event_id]) begin
                    error_flag = 1;
                else begin
                    tmp_event_timestamps[mod_event_id] = new_timestamp;
                    tmp_event_priorities[mod_event_id] = new_priority;
                    tmp_event_valid[mod_event_id] = 1;
                    mod_event_id = -1;
                end
            end

            // Process recurring events
            if (recurring_event) begin
                if (!event_valid[0] && !event_valid[1] && !event_valid[2] && !event_valid[3]) begin
                    cnt = 0;
                end
                cnt = cnt + 1;
                if (cnt >= 1000) begin
                    if (event_valid[0] || event_valid[1] || event_valid[2] || event_valid[3]) begin
                        // Deactivate the first matching recurring event
                        for (int i = 0; i < 4; i = i + 1) {
                            if (event_valid[i]) {
                                event_valid[i] = 0;
                                break;
                            }
                        end
                    end
                    cnt = 0;
                end
                // Update timestamp for recurring event
                if (event_valid[0] || event_valid[1] || event_valid[2] || event_valid[3]) begin
                    if (event_id == 0) begin
                        tmp_event_timestamps[0] = tmp_event_timestamps[0] + recurring_interval;
                    elsif (event_id == 1) begin
                        tmp_event_timestamps[1] = tmp_event_timestamps[1] + recurring_interval;
                    elsif (event_id == 2) begin
                        tmp_event_timestamps[2] = tmp_event_timestamps[2] + recurring_interval;
                    elsif (event_id == 3) begin
                        tmp_event_timestamps[3] = tmp_event_timestamps[3] + recurring_interval;
                    end
                end
            end

            // Add event
            if (add_event) begin
                if (event_valid[mod_event_id]) begin
                    error_flag = 1;
                else begin
                    if (event_valid[event_id]) begin
                        error_flag = 1;
                    else begin
                        tmp_event_timestamps[event_id] = timestamp;
                        tmp_event_priorities[event_id] = priority_in;
                        tmp_event_valid[event_id] = 1;
                    end
                    mod_event_id = event_id;
                end
            end

            // Cancel event
            if (cancel_event) begin
                if (event_id < 4) begin
                    if (tmp_event_valid[event_id]) begin
                        tmp_event_valid[event_id] = 0;
                    end
                end
            end

            // Handle errors
            if (error_flag) begin
                error <= 1;
            end

            // Select and trigger events
            chosen_event = -1;
            for (j = 0; j < 4; j = j + 1) {
                if (tmp_event_valid[j] && (tmp_event_timestamps[j] <= tmp_current_time)) {
                    if ((chosen_event == -1) || (tmp_event_priorities[j] > tmp_event_priorities[chosen_event])) {
                        chosen_event = j;
                    }
                }
            }

            // Trigger event
            if (chosen_event != -1) begin
                event_triggered <= 1;
                triggered_event_id <= chosen_event;
                log_event_time <= tmp_event_timestamps[chosen_event];
                log_event_id <= chosen_event;
                // Clear validity of chosen event
                tmp_event_valid[chosen_event] = 0;
            end else begin
                event_triggered <= 0;
            end

            // Update temporary state
            for (j = 0; j < 4; j = j + 1) begin
                tmp_event_timestamps[j] = event_timestamps[j];
                tmp_event_priorities[j] = event_priorities[j];
                tmp_event_valid[j] = event_valid[j];
            end

            // Apply updates after event selection
            current_time <= tmp_current_time;
            for (j = 0; j < 4; j = j + 1) begin
                event_timestamps[j] <= tmp_event_timestamps[j];
                event_priorities[j] <= tmp_event_priorities[j];
                event_valid[j] <= tmp_event_valid[j];
            end
        end
    end

    // Internal helper variables
    reg [15:0] tmp_current_time = current_time;
    integer cnt = 0;

    // Event selection logic
    integer chosen_event;
    integer i, j;
    integer valid_event;