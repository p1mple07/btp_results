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

localparam PERIOD = CLOCK_HZ / 2;
reg [31:0] count;
reg [31:0] period = PERIOD;
reg [31:0] delay = {PERIOD[31],PERIOD[30],PERIOD[29],PERIOD[28],PERIOD[27],PERIOD[26],PERIOD[25],PERIOD[24],PERIOD[23],PERIOD[22],PERIOD[21],PERIOD[20],PERIOD[19],PERIOD[18],PERIOD[17],PERIOD[16]};
reg strobe = 1'b0;
wire [31:0] delay_plus_one = delay + 1;

always @(posedge clk) begin
	if(!nrst) begin
		count <= 0;
		delay <= delay_plus_one;
		strobe <= 1'b0;
	end else if(enable &&!busy) begin
		count <= count + 1;
		if(count >= delay_plus_one) begin
			strobe <= ~strobe;
			count <= 0;
		end
	end
end

assign soundwave_o = strobe;
assign busy = (count!= 0);
assign done = (start && finish &&!busy);

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

localparam DUTY_CYCLE = 0.8;
localparam PERIOD = PERIOD_US * 1000;
localparam DELAY = (PERIOD*(1.0 - DUTY_CYCLE));

reg [31:0] count;
reg [31:0] period = PERIOD;
reg [31:0] delay = {PERIOD[31],PERIOD[30],PERIOD[29],PERIOD[28],PERIOD[27],PERIOD[26],PERIOD[25],PERIOD[24],PERIOD[23],PERIOD[22],PERIOD[21],PERIOD[20],PERIOD[19],PERIOD[18],PERIOD[17],PERIOD[16]} ;
reg strobe = 1'b0;
wire [31:0] delay_plus_one = delay + 1;

always @(posedge clk) begin
	if(!nrst) begin
		count <= 0;
		delay <= delay_plus_one;
		strobe <= 1'b0;
	end else if(enable &&!busy) begin
		count <= count + 1;
		if(count >= delay_plus_one) begin
			strobe <= ~strobe;
			count <= 0;
		end
	end

assign soundwave_o = strobe;
assign busy = (count!= 0);
assign done = (start && finish &&!busy);

endmodule