reg watchdog_timeout;
reg [2:0] watchdog_counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        watchdog_timeout <= 0;
        watchdog_counter <= 0;
    end else begin
        watchdog_counter <= watchdog_counter + 1;
        if (watchdog_counter >= WATCHDOG_CYCLE_LIMIT) begin
            watchdog_timeout <= 1;
        end else
            watchdog_timeout <= 0;
    end
end
