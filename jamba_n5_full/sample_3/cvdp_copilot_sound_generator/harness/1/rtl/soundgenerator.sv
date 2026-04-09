module soundgenerator (#(
    parameter CLOCK_HZ = 10_000_000
)(
    input wire clk,
    input wire nrst,
    input wire start,
    input wire finish,
    input wire [15:0] sond_dur_ms_i,
    input wire [15:0] half_period_us_i
));

reg [31:0] main_duration;
reg [31:0] half_period_ticks;
reg busy;
reg [15:0] done;

task internal_init;
    main_duration <= 0;
    half_period_ticks <= 0;
    busy <= 0;
    done <= 0;
endtask

internal_init();

always @(posedge clk or negedge nrst) begin
    if (nrst)
        internal_init;
    else
        if (start && ~finish) begin
            busy = 1;
            main_duration = (sond_dur_ms_i * 1000);
            half_period_ticks = half_period_us_i / 2;
        end
end

always_ff @(posedge clk) begin
    if (busy) begin
        if (main_duration > 0) begin
            main_duration = main_duration - 1;
            if (main_duration == 0) begin
                main_duration = 0;
                busy = 0;
                done = 1;
            end
        end
    end else
        busy = 0;
end

always_ff @(posedge clk) begin
    if (busy) begin
        if (half_period_ticks > 0) begin
            half_period_ticks = half_period_ticks - 1;
            if (half_period_ticks == 0) begin
                soundwave_o = !soundwave_o;
            end
        end
    end else
        soundwave_o <= 0;
end

endmodule

module strob_gen (#(
    parameter CLOCK_HZ = 10_000_000
)(
    input wire clk,
    input wire nrst,
    input wire enable,
    output reg strobe_o
));

reg [31:0] strobe;
reg enable_reg;

task internal_strobe;
    if (enable_reg) begin
        strobe <= ~strobe;
    end else
        strobe <= strobe;
endtask

task internal_reset;
    enable_reg <= 0;
endtask

internal_strobe();

always_comb begin
    strobe_o = strobe;
end

endmodule
