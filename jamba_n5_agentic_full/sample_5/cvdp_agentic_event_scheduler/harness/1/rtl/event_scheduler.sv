module event_scheduler (
    input clk,
    input reset,
    input [3:0] add_event,
    input [3:0] cancel_event,
    input [3:0] event_id,
    input [15:0] timestamp,
    input [3:0] priority_in,
    input [3:0] event_triggered,
    output [3:0] triggered_event_id,
    output reg error,
    output reg [15:0] current_time
);

    // Internal registers
    reg [15:0] event_timestamps [0:15];
    reg [15:0] event_priorities [0:15];
    reg [3:0] event_valid [0:15];
    reg tmp_event_timestamps [0:15];
    reg tmp_event_priorities [0:15];
    reg tmp_event_valid [0:15];
    reg current_time;

    // Current time register
    always @(posedge clk) begin
        current_time <= current_time + 10'd1; // 10ns per cycle
    end

    // Wait for clock for tasks
    task wait_clock;
        @(posedge clk);
    endtask

    // Task to wait for trigger event
    task wait_for_trigger(output [3:0] trig_id, output [15:0] trig_time);
        while (event_triggered != 1) begin
            wait_clock;
        end
        trig_id = triggered_event_id;
        trig_time = current_time;
        wait_clock;
    endtask

    // Initialization
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main loop: process events
    task process_events;
        repeat (16) begin
            if (!event_valid[i]) begin
                // Try to add event
                if (add_event) begin
                    // Check if slot free
                    if (event_timestamps[i] == 16'hFFFF && event_priorities[i] == 4'd31) begin
                        error = 1;
                    end else {
                        event_timestamps[i] = current_time;
                        event_priorities[i] = priority_in;
                        event_valid[i] = 1'b1;
                        add_event = 0;
                    }
                end else begin
                    error = 1;
                end
            end

            // Check for cancellation
            if (cancel_event) begin
                if (event_valid[i]) begin
                    event_valid[i] = 0;
                    event_timestamps[i] = 16'hFFFF;
                    event_priorities[i] = 4'd31;
                    add_event = 0;
                end else begin
                    error = 1;
                end
            end
        end
    endtask

    // Trigger event
    task trigger_event;
        assign triggered_event_id = event_id[0];
        assign trig_time = current_time;
        assign event_triggered = 1;

        // Find highest priority eligible event
        integer best_idx = 0;
        for (int i = 0; i < 16; i++) begin
            if (event_valid[i] && event_timestamps[i] <= current_time) begin
                if (event_priorities[i] > (event_priorities[best_idx])) begin
                    best_idx = i;
                end
            end
        end

        if (best_idx != 0) begin
            // Trigger
            event_triggered = 0;
            event_valid[best_idx] = 0;
            event_timestamps[best_idx] = 16'hFFFF;
            event_priorities[best_idx] = 4'd31;
            triggered_event_id = best_idx;
            error = 0;
        end else begin
            error = 1;
        end
    endtask

endmodule
