// -*- coding: utf-8 -*-
// This file is part of the RTL designs documentation.

theorem event_scheduler.sv
    (
        parameter MAX_EVENTS = 16,
        parameter TIMESTAMP_WIDTH = 16,
        parameter PRIORITY_WIDTH = 4,
        parameter THAT_INCREMENT = 10,
        type event_t = integer[3:0],
        type event_info_t = integer[15:0]
    ) -- events are identified by ID (4 bits), timestamp (16 bits), and priority (4 bits)
    (
        input clock,
        input reset,
        input add_event,
        input cancel_event,
        output [3:0] event_id,
        output [15:0] timestamp,
        output [3:0] priority_in,
        output event_triggered,
        output [3:0] triggered_event_id,
        output error,
        output [15:0] current_time
    )
    (
        // event storage and temporary state management
        reg [MAX_EVENTS - 1:0] event_timestamps,
        reg [MAX_EVENTS - 1:0] event_priorities,
        reg [MAX_EVENTS - 1:0] event_valid,
        // temporary copies for atomic updates
        reg [MAX_EVENTS - 1:0] tmp_event_timestamps,
        reg [MAX_EVENTS - 1:0] tmp_event_priorities,
        reg [MAX_EVENTS - 1:0] tmp_event_valid,
        // current time tracking
        reg current_time,
        // control signals
        always begin
            // Time management
            if (!reset) begin
                current_time = 0;
                continue;
            end

            // Event Addition
            if (add_event && !event_valid[event_id]) begin
                // Store new event in temporary arrays
                tmp_event_timestamps[event_id] = timestamp;
                tmp_event_priorities[event_id] = priority_in;
                tmp_event_valid[event_id] = 1;

                // Check if event was already active
                if (event_valid[event_id]) begin
                    error = 1;
                    // $display("Error: Event %d already active", event_id);
                end
            end
            else if (add_event && event_valid[event_id]) begin
                error = 1;
                // $display("Error: Cannot add event %d as it is already active", event_id);
            end

            // Event Cancellation
            if (cancel_event && !event_valid[event_id]) begin
                // Clear event in temporary arrays
                tmp_event_valid[event_id] = 0;
            end
            else if (cancel_event && event_valid[event_id]) begin
                error = 1;
                // $display("Error: Cannot cancel event %d as it is not active", event_id);
            end

            // Event Selection and Triggering
            event_triggered = 0;
            triggered_event_id = 0;
            if (any(tmp_event_valid)) begin
                // Find the highest priority event that has expired
                for (int i = 0; i < MAX_EVENTS; i++) begin
                    if (tmp_event_timestamps[i] <= current_time) begin
                        triggered_event_id = i;
                        event_triggered = 1;
                        break;
                    end
                end
            end

            // Update current_time and commit changes
            current_time = current_time + THAT_INCREMENT;
            foreach (i in 0..MAX_EVENTS - 1) begin
                event_timestamps[i] = tmp_event_timestamps[i];
                event_priorities[i] = tmp_event_priorities[i];
                event_valid[i] = tmp_event_valid[i];
            end
        end
    )