module dig_stopwatch #(parameter CLK_FREQ=50000000)
(
    input wire clk,
    input wire reset,
    input wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    // Internal clock divider to generate one-second pulse
    reg [29:0] counter;
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            seconds <= 0;
            minutes <= 0;
            hour <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == CLK_FREQ - 1) begin
                seconds <= seconds + 1;
                if (seconds == 59) begin
                    minutes <= minutes + 1;
                    seconds <= 0;
                end
                if (minutes == 59) begin
                    hours <= hours + 1;
                    minutes <= 0;
                end
            end
        end
    end

    // Reset logic
    always @(posedge reset) begin
        seconds <= 0;
        minutes <= 0;
        hour <= 0;
    end

    // Start/stop control
    always @(posedge start_stop) begin
        if (start_stop) begin
            // Reset the counter if it was paused
            if (seconds != 0 || minutes != 0 || hour != 0) begin
                counter <= 0;
                seconds <= 0;
                minutes <= 0;
                hour <= 0;
            end
        end else begin
            // Hold current values if paused
            hours <= hour;
            minutes <= minutes;
            seconds <= seconds;
        end
    end

endmodule
