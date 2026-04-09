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

// TickMilli module
module TickMilli(
	input wire clk,
	input wire nrst,
	output reg tick
);
	reg [31:0] counter = 0;
	always @(posedge clk or posedge nrst) begin
		if (nrst)
			counter <= 0;
		else
			counter <= counter + 1;
		tick <= (counter == 1'b100000000);
	end
endmodule

// tickmicro module
module tickmicro(
	input wire clk,
	input wire nrst,
	output reg tick
);
	reg [31:0] counter = 0;
	always @(posedge clk or posedge nrst) begin
		if (nrst)
			counter <= 0;
		else
			counter <= counter + 1;
		tick <= (counter == 1'b1);
	end
endmodule

// Duration Timer
reg [15:0] duration_counter = 0;
wire strobe_active = 1'b0;

always @(posedge clk or posedge nrst) begin
	if (nrst)
		duration_counter <= 16'b0;
	else if (start)
		duration_counter <= sond_dur_ms_i;
	else
		duration_counter <= duration_counter - 1'b1;
	if (duration_counter == 0)
		strobe_active <= 1'b1;
end

// Busy and Done logic
reg busy = 1'b0;
reg done = 1'b0;

always @(posedge clk or posedge nrst) begin
	if (nrst)
		busy <= 1'b0;
	else if (start && !done)
		busy <= 1'b1;
	if (busy && !finish)
		done <= 1'b0;
	else if (busy && finish)
		done <= 1'b1;
end

// Soundwave signal generation
wire halfperiod_counter = 0;
wire strobe_enable = enable;

always @(posedge clk or posedge nrst) begin
	if (nrst)
		halfperiod_counter <= 16'b0;
	else if (strobe_enable)
		halfperiod_counter <= half_period_us_i;
	else
		halfperiod_counter <= halfperiod_counter - 1'b1;
	if (halfperiod_counter == 0)
		strobe_o <= ~strobe_o;
end

// Integration of TickMilli, tickmicro, Duration Timer, and Soundwave signal generation
always @(posedge clk or posedge nrst) begin
	if (nrst)
		soundwave_o <= 1'b0;
	else if (strobe_enable && busy)
		soundwave_o <= strobe_o;
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

// Calculate DELAY
parameter DELAY = CLOCK_HZ * (1000000000 / CLOCK_HZ) / PERIOD_US;

// Instantiate TickMilli and tickmicro modules
TickMilli tmm(clk, nrst, strobe_o);
tickmicro tm(clk, nrst, strobe_o);

// Counter and control logic
reg [31:0] counter = 0;

always @(posedge clk or posedge nrst) begin
	if (nrst)
		counter <= DELAY;
	else if (enable)
		counter <= counter - 1'b1;
	if (counter == 0)
		strobe_o <= ~strobe_o;
end

endmodule
