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

// Internal functionality

// TickMilli module
module TickMilli(
	input wire clk,
	input wire nrst,
	output reg tick
);
	reg [31:0] count;
	always @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			count <= 0;
			tick <= 0;
		end else begin
			if (count == 4_000_000) begin
				tick <= 1;
				count <= 0;
			end else begin
				count <= count + 1;
			end
		end
	end
endmodule

// tickmicro module
module tickmicro(
	input wire clk,
	input wire nrst,
	output reg tick
);
	reg [31:0] count;
	always @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			count <= 0;
			tick <= 0;
		end else begin
			if (count == 1_000_000) begin
				tick <= 1;
				count <= 0;
			end else begin
				count <= count + 1;
			end
		end
	end
endmodule

// Duration Timer
reg [15:0] duration_counter;
always @(posedge clk) begin
	if (nrst) begin
		duration_counter <= 0;
		busy <= 0;
		done <= 0;
	end else if (start) begin
		duration_counter <= sond_dur_ms_i;
		busy <= 1;
		done <= 0;
	end else if (done) begin
		duration_counter <= 0;
		busy <= 0;
		done <= 1;
	end else begin
		if (duration_counter != 0) begin
			duration_counter <= duration_counter - 1;
		end
	end
end

// HalfPeriodTimer
reg [15:0] halfperiod_counter;
always @(posedge clk) begin
	if (nrst) begin
		halfperiod_counter <= half_period_us_i;
	end else begin
		if (enable) begin
			halfperiod_counter <= half_period_us_i;
			if (halfperiod_counter == 0) begin
				soundwave_o <= ~soundwave_o;
				halfperiod_counter <= half_period_us_i;
			end
		end
	end
end

// Soundwave Signal Generation
wire strobe_period_detected;
assign strobe_period_detected = (halfperiod_counter == 0);

assign soundwave_o = (strobe_period_detected && enable) ? ~soundwave_o : 0;

// Reset Behavior
always @(posedge clk) begin
	if (nrst) begin
		duration_counter <= 0;
		halfperiod_counter <= half_period_us_i;
		soundwave_o <= 0;
		busy <= 0;
		done <= 0;
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

// Calculate delay based on clock frequency and period
parameter DELAY = CLOCK_HZ * 1_000_000_000 / PERIOD_US;

reg [31:0] counter;
always @(posedge clk) begin
	if (!nrst) begin
		counter <= DELAY;
		strobe_o <= 0;
	end else begin
		if (counter == 0) begin
			strobe_o <= 1;
			counter <= DELAY;
		end
	end
end

endmodule
