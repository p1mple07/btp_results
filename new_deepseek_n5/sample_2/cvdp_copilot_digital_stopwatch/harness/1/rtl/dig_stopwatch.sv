parameter CLK_FREQ = 50000000;
input clock;
input reset;
input start_stop;

output [5:0] seconds, [5:0] minutes, hour;

// State variables
reg [5:0] sec_counter, min_counter, hour_flag;
reg running;

// Clock divider logic
alwaysposedge clock_edge begin
    if (running) begin
        sec_counter <= 0;
        min_counter <= 0;
        hour_flag <= 0;
        // Generate pulse every second
        if (count_seconds()) begin
            running <= !running;
        end
    end
end

// Counter increment logic
alwaysposedge clock_edge begin
    if (running) begin
        sec_counter <= sec_counter + 1;
        if (sec_counter >= 60) begin
            sec_counter <= 0;
            min_counter <= min_counter + 1;
            if (min_counter >= 60) begin
                min_counter <= 0;
                hour_flag <= 1;
            end
        end
    end
end

// Reset logic
always begin
    if (reset) begin
        sec_counter <= 0;
        min_counter <= 0;
        hour_flag <= 0;
        running <= 1;
    end
end

// Start/Stop logic
always start_stop begin
    if (start_stop) begin
        running <= !running;
    end
end

// Verification logic
always start_stop begin
    // Verify counters are being updated correctly
    // Add verification logic here
end

// Hour overflow handling
alwaysposedge clock_edge begin
    if (hour_flag == 1 && min_counter >= 60) begin
        min_counter <= 0;
        hour_flag <= 0;
    end
end