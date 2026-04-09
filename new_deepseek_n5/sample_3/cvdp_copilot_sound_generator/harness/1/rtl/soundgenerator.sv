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

// Duration counter
reg unsigned [15:0] duration_counter = 0;
always @(posedge start or posedge finish) begin
    if (finish) duration_counter = 0;
    busy = duration_counter != 0;
end

// Half-period counter
reg unsigned [15:0] halfperiod_counter = 0;
always @(posedge start or posedge finish) begin
    if (finish) halfperiod_counter = 0;
    if (halfperiod_counter == 0) begin
        soundwave_o = !soundwave_o;
    end
end

// Main control logic
always @(posedge start or posedge finish) begin
    if (finish) begin
        done = 1;
        busy = 0;
    end
end

// Tickmilli counter
module tickmilli #(
	parameter CLOCK_HZ = 10_000_000
)();
	input wire clk;
	output reg busy_tickmilli;
	output reg done_tickmilli;
	
	// Calculate delay
	parameter DELAY = (1000_000) / CLOCK_HZ; // 1ms delay
	reg unsigned [15:0] tickmilli_counter = 0;
	
	always @(posedge clk) begin
	    if (nrst) begin
	        tickmilli_counter = DELAY;
	        busy_tickmilli = 0;
	    else
	    do
	        tickmilli_counter = (tickmilli_counter + 1) % (1000);
	        busy_tickmilli = 1;
	    end
	end
endmodule

// Tickmicro counter
module tickmicro #(
	parameter CLOCK_HZ = 10_000_000
)();
	input wire clk;
	output reg busy_tickmicro;
	output reg done_tickmicro;
	
	// Calculate delay
	parameter DELAY = 1; // 1us delay
	reg unsigned [15:0] tickmicro_counter = 0;
	
	always @(posedge clk) begin
	    if (nrst) begin
	        tickmicro_counter = DELAY;
	        busy_tickmicro = 0;
	    else
	    do
	        tickmicro_counter = (tickmicro_counter + 1) % (1000000);
	        busy_tickmicro = 1;
	    end
	end
endmodule

// Connect counters to tick modules
tickmilli #(
    CLOCK_HZ = CLOCK_HZ
).tickmilliclk(clk);
tickmicro #(
    CLOCK_HZ = CLOCK_HZ
).tickmicroclk(clk);

// Sound generation logic
always @(posedge start or posedge finish) begin
    if (finish) begin
        busy = 0;
        done = 1;
    end
end

endmodule

module strob_gen #(
	parameter	CLOCK_HZ	= 10_000_000,
	parameter	PERIOD_US	= 100
)();
	input wire  clk,
	input wire  nrst,
	input wire  enable,
	output reg  strobe_o
);
	
	// Calculate delay
	parameter DELAY = (PERIOD_US * 1000) / CLOCK_HZ;
	
	// Initialize counter
	reg unsigned [15:0] counter = 0;
	
	// Always active to prevent计数器 from being reset
	always begin
	    if (nrst) begin
	        counter = DELAY;
	        strobe_o = 0;
	    else
	    do
	        counter = counter + 1;
	        if (counter == DELAY) begin
	            strobe_o = 1;
	            counter = 0;
	        end
	    end
	end
endmodule