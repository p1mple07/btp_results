module dig_stopwatch #(parameter CLK_FREQ = 50000000)(
    input  logic         clk,
    input  logic         reset,
    input  logic         start_stop,
    output logic [5:0]   seconds,
    output logic [5:0]   minutes,
    output logic         hour
);

    // Internal clock divider signals
    logic         one_sec_pulse;
    logic [31:0]  count;           // Counts clock cycles to generate a 1-second pulse

    // Register to detect the rising edge of one_sec_pulse
    logic         one_sec_pulse_prev;

    // Clock divider: generates a one-cycle pulse every second
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count        <= 0;
            one_sec_pulse<= 0;
        end else begin
            if (count == CLK_FREQ - 1) begin
                count        <= 0;
                one_sec_pulse<= 1;
            end else begin
                count        <= count + 1;
                one_sec_pulse<= 0;
            end
        end
    end

    // Stopwatch counter update: triggered on the rising edge of one_sec_pulse
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            seconds      <= 0;
            minutes      <= 0;
            hour         <= 0;
            one_sec_pulse_prev <= 0;
        end else begin
            // Save previous pulse value for edge detection
            one_sec_pulse_prev <= one_sec_pulse;
            
            // Update counters only on the rising edge of the one-second pulse,
            // if the stopwatch is running and not already at one hour.
            if (one_sec_pulse && !one_sec_pulse_prev && start_stop && (hour != 1)) begin
                if (seconds == 59) begin
                    seconds <= 0;
                    if (minutes == 59) begin
                        minutes <= 0;
                        hour    <= 1;  // Set hour to 1 when one hour has elapsed
                    end else begin
                        minutes <= minutes + 1;
                    end
                end else begin
                    seconds <= seconds + 1;
                end
            end
        end
    end

endmodule