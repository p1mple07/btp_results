module soundgenerator #(
    parameter  CLOCK_HZ = 10_000_000
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

localparam CLOCK_DIV = 10000000 / CLOCK_HZ;

reg TickMilli;
reg tickmicro;
reg [63:0] counter;
reg [63:0] delay;
reg [63:0] halfperiod;

always @(posedge clk or posedge finish or posedge nrst) begin
    if (nrst) begin
        counter <= 0;
        done <= 1'b0;
        busy <= 1'b0;
        soundwave_o <= 1'b0;
    end else begin
        if (start) begin
            counter <= 64'd0;
        end else begin
            if (counter > 0) begin
                counter <= counter - 1;
            end else begin
                counter <= 64'd0xFFFF_FFF8; // reset to maximum value
            end
        end
    end
end

always @(posedge clk) begin
    if (done) begin
        soundwave_o <= 1'b0;
        done <= 1'b0;
        busy <= 1'b0;
    end else begin
        if (tickmilli_pulse) begin
            tickmilli_pulse <= ~tickmilli_pulse;
        end
        if (tickmilli_pulse && tickmicro_pulse) begin
            soundwave_o <= 1'b1;
        end else if (tickmilli_pulse) begin
            tickmilli_pulse <= ~tickmilli_pulse;
        end
    end
end

always @(posedge clk) begin
    if (tickmicro_pulse) begin
        halfperiod <= halfperiod + half_period_us_i * CLOCK_DIV / 1000;
        if (halfperiod >= half_period_us_i) begin
            done <= 1'b1;
        end else if (done) begin
            done <= 1'b0;
        end
    end
end

endmodule

module strob_gen #(
    parameter  CLOCK_HZ = 10_000_000,
    parameter  PERIOD_US = 100
)(
    input wire clk,
    input wire nrst,
    input wire enable,
    output reg strobe_o
);

reg counter;

always @(*) begin
    counter = 0;
end

always @(posedge clk) begin
    if (enable) begin
        counter <= counter + 1;
    end
end

always @(posedge clk) begin
    if (counter == 64'hFFFF_FFF8) begin
        strobe_o <= 1'b1;
    end else begin
        strobe_o <= 1'b0;
    end
end

endmodule
