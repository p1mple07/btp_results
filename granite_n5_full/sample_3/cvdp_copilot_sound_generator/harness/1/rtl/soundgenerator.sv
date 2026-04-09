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

//insert your code here

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
//insert your code here

endmodule