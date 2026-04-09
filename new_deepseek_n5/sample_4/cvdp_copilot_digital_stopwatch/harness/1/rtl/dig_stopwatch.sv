module dig_stopwatch (
    input clock,
    input reset,
    input start_stop,
    output [5:0] seconds,
    output [5:0] minutes,
    output hour
);

    // State machine states
    state state = State::IDLE;
    state running, paused, reset_state;

    // Time counters
    reg [5:0] time_seconds = 0;
    reg [5:0] time_minutes = 0;
    reg hour_count = 0;

    // Internal clock divider control
    reg [3:0] counter = 0;

    // Pulse generation control
    reg pulse_valid = 0;

    // State transitions
    always_comb state_next = case {
        State::IDLE: start_stop ? running : IDLE,
        running: start_stop ? paused : running,
        paused: start_stop ? reset_state : paused,
        reset_state: reset ? reset_state : running
    };

    // Pulse generation
    always posedge clock begin
        if (counter == 60 && state == running) begin
            time_seconds = 0;
            time_minutes = 0;
            hour_count = 0;
            pulse_valid = 1;
            counter = 0;
        end
        else if (counter < 60) counter = counter + 1;
    end

    // Time update
    always posedge pulse_valid begin
        time_seconds = $signed(time_seconds + 1);
        time_seconds = time_seconds & 0x1F;
        if (time_seconds == 60) begin
            time_seconds = 0;
            time_minutes = $signed(time_minutes + 1);
            time_minutes = time_minutes & 0x1F;
            if (time_minutes == 60) begin
                time_minutes = 0;
                hour_count = $signed(hour_count + 1);
                hour_count = hour_count & 1;
            end
        end
    end

    // State machine update
    always posedge clock begin
        if (pulse_valid) begin
            state = state_next;
        end
    end

    // Output the current time
    assign [5:0] seconds = time_seconds;
    assign [5:0] minutes = time_minutes;
    assign hour = hour_count;
endmodule