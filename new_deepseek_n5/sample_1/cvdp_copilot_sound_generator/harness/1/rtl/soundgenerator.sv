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

// Internal modules
module TickMilli #(
	parameter	PERIOD = 1_000
)(
	input wire  clk,
	input wire  nrst,
	output reg  pulse_o
);
// Millisecond precision timing
always @(posedge clk or posedge nrst) begin
    if (nrst) begin
        pulse_o = 0;
    else
        pulse_o = ~pulse_o;
    end
end

module TickMicro #(
	parameter	PERIOD = 1
)(
	input wire  clk,
	input wire  nrst,
	output reg  pulse_o
);
// Microsecond precision timing
always @(posedge clk or posedge nrst) begin
    if (nrst) begin
        pulse_o = 0;
    else
        pulse_o = ~pulse_o;
    end
end

// Duration counter
reg duration_counter = 0;
reg busy = 0;
reg done = 0;
reg finish = 0;
reg halfperiod_timer = 0;

// Internal signals
wire always @(posedge clk) begin
    if (nrst) begin
        duration_counter = (sond_dur_ms_i / 1000) + 1;
        halfperiod_timer = (half_period_us_i / 1000) + 1;
        busy = 0;
        done = 0;
    end
    else if (start) begin
        busy = 1;
        // Start duration counter
        initial begin
            duration_counter = (sond_dur_ms_i / 1000) + 1;
        end
        // Start halfperiod counter
        initial begin
            halfperiod_timer = (half_period_us_i / 1000) + 1;
        end
    end
end

// Generate soundwave
always @(posedge finish or posedge busy) begin
    if (busy) begin
        if (halfperiod_timer == 0) begin
            soundwave_o = ~soundwave_o;
            halfperiod_timer = (half_period_us_i / 1000) + 1;
        end
    end
end

// Reset all internal states
always @(posedge clk or posedge nrst) begin
    if (nrst) begin
        duration_counter = (sond_dur_ms_i / 1000) + 1;
        halfperiod_timer = (half_period_us_i / 1000) + 1;
        busy = 0;
        done = 0;
    end
end

module strob_gen #(
	parameter	CLOCK_HZ	= 10_000_000,
	parameter	PERIOD_US	= 100
)(
	input wire  clk,
	input wire  nrst,
	input wire  enable,
	output reg  strobe_o
);
// Generates periodic strobe signal
reg strobe_o = 0;
always @(posedge clk or posedge nrst) begin
    if (enable) begin
        if (strobe_o == 0) begin
            strobe_o = 1;
            // Calculate delay
            for (integer i = 0; i < (10_000_000 / PERIOD_US); i = i + 1) begin
                strobe_o = 0;
            end
        end
    else
        strobe_o = 0;
    end
end

endmodule

endmodule