module soundgenerator #(
	parameter  CLOCK_HZ = 10_000_000
)(
	input wire clk,                                         //input clock signal with frequency 10Mhz
	input wire nrst,                                        //active low asynchronous reset.
	
	input wire start,                                       //indicate the start of the operation.
	input wire finish,                                      //indicate the end of operation.
	input wire [15:0] sond_dur_ms_i,                        //this signal indicate for how much time the sound should be generated in millisecond.
	input wire [15:0] half_period_us_i,                     //this signal indicate the frequency of the output signal by giving the half time period required for the output soundwave_o 
	
	output wire soundwave_o,                                //output sound wave signal.
	output wire busy,                                       //indicate the system is busy.
	output wire done                                        //indicate the operation is completed.
);

// Duration timer setup
reg duration_counter = 0;
reg busy = 0;
reg finish = 0;

// Half-period timer setup
reg halfperiod_counter = 0;

// Internal signals
wire TickMilli_strobe;
wire tickmicro_strobe;

// Generate TickMilli pulses for duration control
strob_gen#(CLOCK_HZ, 1000) TickMilli(clk, nrst, TickMilli_strobe);

// Generate tickmicro pulses for frequency control
strob_gen#(CLOCK_HZ, 1000000) tickmicro(clk, nrst, tickmicro_strobe);

always_ff @(posedge TickMilli_strobe) begin
    if (!nrst) begin
        duration_counter = 0;
        busy = 0;
        finish = 0;
        halfperiod_counter = 0;
    end
    duration_counter = duration_counter + 1;
    if (duration_counter >= (sond_dur_ms_i >> 15)) begin
        busy = 1;
        if (!finish) begin
            if (halfperiod_counter == 0) begin
                busy = 0;
            end
        end
    end
end

always_ff @(posedge tickmicro_strobe) begin
    if (!nrst) begin
        halfperiod_counter = 0;
        busy = 0;
        finish = 0;
    end
    halfperiod_counter = halfperiod_counter + 1;
    if (halfperiod_counter >= (half_period_us_i >> 15)) begin
        busy = 0;
        soundwave_o = !soundwave_o;
    end
end

// Set final output when done
always @(posedge finish) begin
    if (finish && busy) begin
        done = 1;
        busy = 0;
    end
end

endmodule

module strob_gen #(
	parameter	CLOCK_HZ	= 10_000_000,
	parameter	PERIOD_US	= 100
)(
	input wire  clk,
	input wire  nrst,
	input wire  enable,
	output reg  strobe_o
);
	
	// Calculate delay based on clock and period
	parameter DELAY = (CLOCK_HZ / 1000000) * PERIOD_US;
	
	reg count = 0;
	
(always_ff @(posedge clk or posedge nrst) begin
    if (enable) begin
        if (count >= DELAY) begin
            strobe_o = 1;
            count = 0;
        end
        count = count + 1;
    else
        count = DELAY;
    end
end

endmodule