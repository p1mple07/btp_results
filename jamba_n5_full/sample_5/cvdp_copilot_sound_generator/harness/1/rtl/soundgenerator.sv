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
localvar int counter;

initial begin
    tickmilli = 0;
    tickmicro = 0;
    counter = half_period_us_i;
end

always @(posedge clk) begin
    if (!nrst) begin
        tickmilli = 0;
        tickmicro = 0;
        counter = half_period_us_i;
        busy = 1'b0;
        done = 1'b0;
        soundwave_o = 1'b0;
    end else begin
        if (start) begin
            tickmilli = 0;
            tickmicro = 0;
            counter = half_period_us_i;
            busy = 1'b1;
            done = 1'b0;
            soundwave_o = 1'b0;
        end else begin
            tickmilli = tickmilli + 1;
            tickmicro = tickmicro + 1;
            if (tickmilli >= 1000) begin // 1ms
                tickmilli = tickmilli - 1000;
                if (tickmilli == 0) begin
                    tickmilli = 1000;
                    tickmicro = 0;
                end
            end
        end
    end
end

always @(posedge tickmilli) begin
    if (counter > 0) begin
        counter = counter - 1;
    end
end

always @(posedge tickmicro) begin
    if (half_period_us_i > 0) begin
        if (counter == 0) begin
            counter = half_period_us_i / 2;
        end else begin
            counter = counter - 1;
        end
    end
end

assign soundwave_o = (busy && soundwave_state); // we need to know the state.

wire soundwave_state;

always @(*) begin
    if (busy) begin
        soundwave_state = half_period_us_i % 2 == 0; // toggle each half-period
    end else begin
        soundwave_state = 1'b0;
    end
end

assign soundwave_o = soundwave_state;

assign busy = busy;
assign done = done;

endmodule

module strob_gen #(
    parameter CLOCK_HZ = 10_000_000,
    parameter PERIOD_US = 100
)(
    input wire clk,
    input wire nrst,
    input wire enable,
    output reg strobe_o
);

reg strobe;

always @(negedge clk) begin
    if (enable) begin
        strobe = !strobe;
    end
end

assign strobe_o = strobe;

endmodule
