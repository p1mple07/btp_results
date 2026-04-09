
module soundgenerator #(
    parameter CLOCK_HZ = 10_000_000
)(
    input wire clk,
    input wire nrst,
    input wire start,
    input wire finish,
    input wire [15:0] sond_dur_ms_i,
    input wire [15:0] half_period_us_i,

    output wire soundwave_o,
    output wire busy,
    output wire done
);

reg [31:0] tickmilli;
reg [31:0] tickmicro;
reg duration_counter;
reg halfperiodtimer;
reg [2:0] state;

always @(posedge clk or posedge nrst) begin
    if (rst) begin
        tickmilli <= 0;
        tickmicro <= 0;
        duration_counter <= 0;
        halfperiodtimer <= 0;
        soundwave_o <= 0;
        busy <= 0;
        done <= 0;
    end else begin
        if (start) begin
            tickmilli <= 1000; // 1ms per tick
            tickmicro <= 1000;
            state <= 0;
            duration_counter <= sond_dur_ms_i * 1000;
            halfperiodtimer <= half_period_us_i * 500;
            busy <= 1;
        end
    end
end

always @(posedge clk or posedge nrst) begin
    if (!started) begin
        // ... but maybe we can handle after start
    end
end

always @(posedge clk) begin
    if (state == 0) begin
        if (duration_counter > 0) begin
            if (tickmilli > 0) begin
                tickmilli <= tickmilli - 1;
            end else begin
                state <= 1;
            end
        end else begin
            state <= 2;
            if (tickmicro > 0) begin
                tickmicro <= tickmicro - 1;
            end else begin
                state <= 3;
                if (tickmicro == 0) begin
                    done <= 1;
                end
            end
        end
    end end
end

always @(posedge clk) begin
    if (state == 1) begin
        soundwave_o = 1;
    end else if (state == 2) begin
        soundwave_o = 0;
    end else if (state == 3) begin
        soundwave_o = 1;
    end
end

always @(posedge clk) begin
    if (state == 3) begin
        done <= 1;
    end
end

endmodule
