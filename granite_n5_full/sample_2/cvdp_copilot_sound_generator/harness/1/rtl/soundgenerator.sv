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

reg [31:0] COUNT;
reg [31:0] DELAY;
reg [31:0] TICKCOUNT;
reg [31:0] TICKCOUNT2;
reg [31:0] TICKS;
reg [31:0] DURATION;

always @(posedge clk) begin 
	if(enable) begin 
		if(TICKS == TICKCOUNT) begin
			soundwave_o <= ~soundwave_o; 
			TICKS <= TICKCOUNT2; 
		end
		else if(TICKS == TICKCOUNT2) begin
			soundwave_o <= 0;
			TICKS <= 0;
		end
		else
			TICKS <= TICKS + 1;
		
		DURATION <= DURATION - 1;
	end 
	else begin
		DURATION <= sond_dur_ms_i * 1000;
		TICKS <= 0;
		TICKCOUNT <= (CLOCK_HZ / (half_period_us_i * 1000)) - 1;
		TICKCOUNT2 <= 2 * (CLOCK_HZ / (half_period_us_i * 1000)) - 1;
	end
end

assign busy = (TICKS > 0);
assign done = (DURATION <= 0) && (TICKS == TICKCOUNT);

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

initial begin
	$display("Hello World");
end

endmodule