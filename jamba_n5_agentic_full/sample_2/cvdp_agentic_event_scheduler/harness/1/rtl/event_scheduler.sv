module event_scheduler;

    parameter MAX_EVENTS = 16;
    parameter TIMESTAMP_WIDTH = 16;
    parameter PRIORITY_WIDTH = 4;
    parameter TIME_INCREMENT = 10;

    // Internal state variables
    reg [TIMESTAMP_WIDTH-1:0] event_timestamps;
    reg [PRIORITY_WIDTH-1:0] event_priorities;
    reg [1:0] event_valid;

    // Temporary arrays for atomic updates
    reg [TIMESTAMP_WIDTH-1:0] tmp_event_timestamps;
    reg [PRIORITY_WIDTH-1:0] tmp_event_priorities;
    reg tmp_event_valid;

    // Timers
    reg [MAX_EVENTS-1:0] current_time;
    reg clk;
    reg reset;

    // Signals
    wire event_triggered;
    wire [3:0] triggered_event_id;
    wire error;
    wire [15:0] current_time_local;

    // Internal tasks
    task async wait_clock;
        @(posedge clk);
    endtask

    task async wait_for_trigger;
        begin
            while (event_triggered !== 1) begin
                wait_clock;
            end
            trig_id = triggered_event_id;
            trig_time = current_time;

            wait_clock;
        end
    endtask

    // Main clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Add event
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            event_timestamps <= { {MAX_EVENTS*{1'b0}} };
            event_priorities <= { {MAX_EVENTS*{1'b0}} };
            event_valid <= { {MAX_EVENTS*1'b0} };
            current_time <= 0;
        end else begin
            if (add_event) begin
                if (event_timestamps[event_id] == 1'b0) begin
                    event_timestamps[event_id] = current_time + TIME_INCREMENT;
                    event_priorities[event_id] = priority_in;
                    event_valid[event_id] = 1'b1;
                end else begin
                    error = 1'b1;
                end
            end else if (cancel_event) begin
                if (event_valid[event_id]) begin
                    event_valid[event_id] = 1'b0;
                end else begin
                    error = 1'b1;
                end
            end else begin
                error = 1'b1;
            end
        end
    endtask

    // Trigger event selection
    always @(posedge clk) begin
        if (event_triggered !== 1) begin
            current_time_local = current_time + TIME_INCREMENT;
            while (current_time_local < future_time) begin
                wait_clock;
            end
            if (event_triggered !== 1) begin
                // Find eligible event
                for (int i = 0; i < MAX_EVENTS; i++) begin
                    if (event_valid[i] && event_timestamps[i] <= current_time_local) begin
                        // Compare priority
                        if (event_priorities[i] > 0) begin
                            if (event_priorities[i] > 0) begin
                                // Choose highest priority
                                triggered_event_id = i;
                                event_triggered = 1;
                                current_time_local = current_time;
                            end
                        end
                    end
                }
            end
        end
    endtask

endmodule
