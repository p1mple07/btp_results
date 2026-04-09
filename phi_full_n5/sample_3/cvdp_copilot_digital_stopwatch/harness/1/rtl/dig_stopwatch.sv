module dig_stopwatch #(parameter CLK_FREQ = 50000000) (
    input wire clk,
    input wire reset,
    input wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    reg [31:0] sec_count, min_count, hour_count;
    integer i;

    // Internal clock divider to generate one-second pulse
    always_ff @(posedge clk) begin
        if (!reset) begin
            sec_count <= 0;
            min_count <= 0;
            hour_count <= 0;
        end else if (sec_count == CLK_FREQ - 1) begin
            sec_count <= 0;
            min_count <= min_count + 1;
            if (min_count == CLK_FREQ - 1) begin
                min_count <= 0;
                hour_count <= hour_count + 1;
                if (hour_count == CLK_FREQ - 1) begin
                    hour_count <= 0;
                    seconds <= 0;
                end
            end
        end else begin
            sec_count <= sec_count + 1;
        end
    end

    // Reset logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            seconds <= 0;
            minutes <= 0;
            hour <= 0;
        end else if (start_stop) begin
            seconds <= seconds;
            minutes <= minutes;
            hour <= hour;
        end
    end

    // Start/Stop logic
    always_ff @(posedge clk or posedge start_stop) begin
        if (start_stop) begin
            seconds <= 0;
            minutes <= 0;
            hour <= 0;
        end
    end

endmodule
