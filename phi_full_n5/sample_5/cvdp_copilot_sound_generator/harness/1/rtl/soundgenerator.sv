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
TickMilli tick_milli(clk, nrst, busy);
TickMicro tickmicro(clk, nrst, halfperiodtimer, strobe_o);

// Timing Generators
wire strobe_enable, strobe_load;
assign strobe_enable = start && !finish;
assign strobe_load = half_period_us_i > 0;

// Duration Timer
reg [15:0] duration_counter;
always @(posedge clk) begin
    if (nrst) begin
        duration_counter <= 16'd0;
    end else if (strobe_enable && strobe_load) begin
        if (duration_counter >= sond_dur_ms_i) begin
            duration_counter <= 0;
            busy <= 1;
        end else begin
            duration_counter <= duration_counter + 1;
        end
    end
end

// Completion Detection
reg done_flag;
always @(posedge clk) begin
    if (done_flag) begin
        done <= 1;
    end
end
assign done_flag = ~busy;

// Soundwave Signal Generation
reg [15:0] halfperiod_counter;
always @(posedge clk) begin
    if (nrst) begin
        halfperiod_counter <= 16'd0;
    end else if (strobe_enable && strobe_load) begin
        if (halfperiod_counter >= half_period_us_i) begin
            halfperiod_counter <= 0;
            strobe_o <= ~strobe_o;
        end else begin
            halfperiod_counter <= halfperiod_counter + 1;
        end
    end
end

// Reset Behavior
always @(negedge nrst) begin
    duration_counter <= 16'd0;
    halfperiod_counter <= 16'd0;
    busy <= 0;
    done <= 0;
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

// Calculate delay value
parameter DELAY_US = (CLOCK_HZ * 1000000) / PERIOD_US;

// Counter
reg [31:0] counter;

// Initialize counter
always @(posedge clk) begin
    if (nrst) begin
        counter <= DELAY_US;
    end else if (enable) begin
        counter <= DELAY_US;
    end
end

// Generate strobe signal
always @(posedge clk) begin
    if (counter == 0) begin
        strobe_o <= 1;
        counter <= DELAY_US;
    end else begin
        counter <= counter - 1;
    end
end

endmodule
