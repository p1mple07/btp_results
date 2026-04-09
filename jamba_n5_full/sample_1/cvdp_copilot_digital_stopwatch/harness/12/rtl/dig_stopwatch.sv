module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,
    input wire reset,
    input wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    localparam COUNTER_MAX = CLK_FREQ - 1;
    reg [$clog2(COUNTER_MAX):0] counter;
    reg one_sec_pulse;
    reg load_deasserted;
    reg load_done;
    reg start_flag;
    reg[] load_values;

    initial begin
        resetn <= 1'b1;
        counter <= 0;
        seconds <= 6'b0;
        minutes <= 6'b0;
        hour <= 1'b0;
        load_deasserted = 1'b1;
        load_done = 1'b0;
        start_flag = 1'b0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
            load_deasserted = 1'b1;
            load_done = 1'b0;
            start_flag = 1'b0;
        end else begin
            if (start_stop) begin
                start_flag = 1'b1;
            end else if (start_stop == 1 && hour == 0) begin
                if (seconds < 59) begin
                    seconds <= seconds + 1'b1;
                end else begin
                    seconds <= 6'b0;
                    if (minutes < 59) begin
                        minutes <= minutes + 1'b1;
                    end else begin
                        minutes <= 6'b0;
                        hour <= 1'b1;
                    end
                end
            end
        end
    end

    always @(posedge clk) begin
        if (start_flag && !load_deasserted) begin
            if (seconds > 0) begin
                seconds <= seconds - 1'b1;
                one_sec_pulse <= 1'b1;
            end else begin
                seconds <= 6'b0;
                one_sec_pulse <= 1'b0;
            end
        end else begin
            // No action needed
        end
    end

    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (start_stop == 1 && hour == 0) begin
            if (seconds < 59) begin
                seconds <= seconds + 1'b1;
            end else begin
                seconds <= 6'b0;
                if (minutes < 59) begin
                    minutes <= minutes + 1'b1;
                end else begin
                    minutes <= 6'b0;
                    hour <= 1'b1;
                end
            end
        end
    end

endmodule
