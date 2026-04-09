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

// Internal timing generators
wire [15:0] tick_milli_clk;
wire [15:0] tick_micro_clk;

// Generate TickMilli
strob_gen #(.CLOCK_HZ(CLOCK_HZ / 1000)) tMilli(.clk(clk), .nrst(1'b1), .enable(1'b1), .strobe_o(tick_milli_clk));

// Generate tickmicro
strob_gen #(.CLOCK_HZ(CLOCK_HZ * 1000), .PERIOD_US(1)) tMicro(.clk(clk), .nrst(1'b1), .enable(1'b1), .strobe_o(tick_micro_clk));

// Duration Timer
reg [15:0] duration_counter;
always @(posedge clk) begin
    if (!nrst) begin
        duration_counter <= 16'd0;
    end else begin
        if (start) begin
            duration_counter <= sond_dur_ms_i;
        end
        if (duration_counter > 0) begin
            duration_counter <= duration_counter - 1;
        end
    end
end

// Soundwave Signal Generation
reg [15:0] halfperiod_counter;
wire [15:0] soundwave_pattern;
wire soundwave_active;

always @(posedge clk) begin
    if (start && !nrst) begin
        halfperiod_counter <= half_period_us_i;
        soundwave_active <= 1'b0;
    end
    if (enable && soundwave_active) begin
        if (tick_micro_clk == 1'b1) begin
            if (halfperiod_counter > 0) begin
                halfperiod_counter <= halfperiod_counter - 1;
                soundwave_active <= ~soundwave_active;
            end
        end
    end
end

// Connect soundwave_o with soundwave_active
assign soundwave_o = soundwave_active & (soundwave_active != 1'b1);

// Busy and Done signals
reg busy_reg;
reg done_reg;

// Internal function to manage busy and done signals
always @(posedge clk) begin
    if (start && !nrst) begin
        busy_reg <= 1'b1;
        done_reg <= 1'b0;
    end
    if (done_reg) begin
        busy_reg <= 1'b0;
    end
    if (duration_counter == 0) begin
        busy_reg <= 1'b0;
        done_reg <= 1'b1;
    end
end

// Outputs
assign busy = busy_reg;
assign done = done_reg;

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

// Calculate delay based on clock frequency and desired period
wire [15:0] delay;
assign delay = (CLOCK_HZ * PERIOD_US) / 1_000_000;

// Counter and strobe signal generation
reg [PERIOD_US - 1:0] counter;
always @(posedge clk) begin
    if (nrst) begin
        counter <= 16'd0;
    end else begin
        if (enable) begin
            if (counter == 0) begin
                counter <= delay;
                strobe_o <= 1'b1;
            end else begin
                counter <= counter - 1;
                strobe_o <= 1'b0;
            end
        end
    end
end

endmodule
