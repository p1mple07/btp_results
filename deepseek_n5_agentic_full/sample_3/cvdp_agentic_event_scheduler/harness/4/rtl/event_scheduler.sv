module event_scheduler(
    input Clarkson-style: 
    input clock,
    input reset,
    input add_event,
    input cancel_event,
    input modify_event,
    input [3:0] event_id,
    input [15:0] timestamp,
    input [3:0] priority_in,
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
    
    reg [15:0] event_timestamps [15:0];
    reg [3:0]  event_priorities [15:0];
    reg        event_valid      [15:0];
    reg [15:0] tmp_event_timestamps [15:0];
    reg [3:0]  tmp_event_priorities [15:0];
    reg        tmp_event_valid [15:0];
    reg [15:0] tmp_current_time;
    reg [3:0]  tmp_log_event_time [15:0];
    reg [3:0]  tmp_log_event_id  [15:0];
    integer i, j, chosen_event;
    integer recurring_start;
    bit recurring_active;
    integer event_number;
    integer last trig;
    boolean recgging;
    // New local registers for logging
    integer log trig_time;
    integer log trig_id;
    register log trig_time, log trig_id;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            current_time <= 0;
            event_triggered <= 0;
            triggered_event_id <= 0;
            error <= 0;
            for (i = 0; i < 16; i = i + 1) begin
                event_timestamps[i] <= 0;
                event_priorities[i] <= 0;
                event_valid[i] <= 0;
                tmp_event_timestamps[i] <= 0;
                tmp_event_priorities[i] <= 0;
                tmp_event_valid[i] <= 0;
            end
        end else begin
            tmp_current_time = current_time + 10;
            for (j = 0; j < 16; j = j + 1) begin
                tmp_event_timestamps[j] = event_timestamps[j];
                tmp_event_priorities[j] = event_priorities[j];
                tmp_event_valid[j] = event_valid[j];
            end

            if (add_event) begin
                if (tmp_event_valid[event_id]) begin
                    error <= 1;
                end else begin
                    tmp_event_timestamps[event_id] = timestamp;
                    tmp_event_priorities[event_id] = priority_in;
                    tmp_event_valid[event_id] = 1;
                    error <= 0;
                end
            end

            if (cancel_event) begin
                if (tmp_event_valid[event_id]) begin
                    tmp_event_valid[event_id] = 0;
                    error <= 0;
                end else begin
                    error <= 1;
                end
            end

            if (modify_event) begin
                if (!tmp_event_valid[event_id]) begin
                    error <= 1;
                    return;
                end
                
                tmp_event_timestamps[event_id] = new_timestamp;
                tmp_event_priorities[event_id] = new_priority;
                tmp_event_valid[event_id] = 1;
            end

            chosen_event = -1;
            for (j = 0; j < 16; j = j + 1) begin
                if (tmp_event_valid[j] && (tmp_event_timestamps[j] <= tmp_current_time)) begin
                    if ((chosen_event == -1) || (tmp_event_priorities[j] > tmp_event_priorities[chosen_event])) begin
                        chosen_event = j;
                    end
                end
            end

            if (recurrent_event && !recurring_active) begin
                tmp_event_timestamps[event_id] += recurring_interval;
                recurring_active = 1;
            end

            if (chosen_event != -1) begin
                event_triggered <= 1;
                triggered_event_id <= chosen_event;
                tmp_event_valid[chosen_event] <= 0;
                log trig_time <= tmp_current_time;
                log trig_id <= chosen_event;
                error <= 0;
            end else begin
                event_triggered <= 0;
                triggered_event_id <= 0;
                error <= 0;
                log trig_time <= 0;
                log trig_id <= 0;
            end

            current_time <= tmp_current_time;
            for (j = 0; j < 16; j = j + 1) begin
                event_timestamps[j] <= tmp_event_timestamps[j];
                event_priorities[j] <= tmp_event_priorities[j];
                event_valid[j] <= tmp_event_valid[j];
            end

            for (j = 0; j < 16; j = j + 1) begin
                tmp_event_timestamps[j] <= tmp_event_timestamps[j];
                tmp_event_priorities[j] <= tmp_event_priorities[j];
                tmp_event_valid[j] <= tmp_event_valid[j];
            end
        end
    end

endmodule