module dig_stopwatch #(parameter integer CLK_FREQ = 50000000) (
    input  logic clk,
    input  logic reset,
    input  logic start_stop,
    output logic [5:0] seconds,
    output logic [5:0] minutes,
    output logic hour
);

    // Internal registers for clock division and one-second pulse generation
    logic [31:0] clk_divider;
    logic        sec_pulse;

    // Clock divider: counts input clock cycles and generates a one-cycle pulse every second.
    // When start_stop is low (paused), the divider holds its current value.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider <= 32'd0;
            sec_pulse   <= 1'b0;
        end else if (start_stop) begin
            if (clk_divider == (CLK_FREQ - 1)) begin
                sec_pulse   <= 1'b1;
                clk_divider <= 32'd0;
            end else begin
                sec_pulse   <= 1'b0;
                clk_divider <= clk_divider + 1;
            end
        end else begin
            // Paused: do not update the clock divider; retain the partial count.
            sec_pulse <= 1'b0;
        end
    end

    // Stopwatch counters: update seconds, minutes, and hour on the rising edge of sec_pulse.
    // Counting stops when hour becomes 1.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            seconds <= 6'd0;
            minutes <= 6'd0;
            hour    <= 1'b0;
        end else if (sec_pulse && (hour == 1'b0)) begin
            seconds <= seconds + 1;
            if (seconds == 6'd60) begin
                seconds <= 6'd0;
                minutes <= minutes + 1;
                if (minutes == 6'd60) begin
                    minutes <= 6'd0;
                    hour    <= 1'b1;
                end
            end
        end
    end

endmodule