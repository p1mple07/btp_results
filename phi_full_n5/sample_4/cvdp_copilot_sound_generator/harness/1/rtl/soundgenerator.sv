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

// Internal signals and timers
reg [15:0] duration_counter;
reg [15:0] halfperiod_counter;
reg [15:0] tick_counter;
reg [15:0] strobe_counter;
reg [15:0] tick_count;
reg [15:0] halfperiod_count;

// Instantiate the strob_gen modules
strob_gen #(CLOCK_HZ, PERIOD_US) strob_gen_tckm_1 (.clk(clk), .nrst(nrst), .enable(start), .strobe_o(tick_counter));
strob_gen #(CLOCK_HZ, PERIOD_US/2) strob_gen_tickm_1 (.clk(clk), .nrst(nrst), .enable(start), .strobe_o(halfperiod_counter));

// Main module logic
always @(posedge clk) begin
    if (nrst) begin
        duration_counter <= 0;
        halfperiod_counter <= 0;
        strobe_counter <= 0;
        tick_counter <= 0;
        halfperiod_count <= 0;
        tick_count <= 0;
    end else begin
        if (start) begin
            if (nrst) begin
                // Reset counters and outputs
                duration_counter <= sond_dur_ms_i;
                halfperiod_counter <= half_period_us_i;
                strobe_counter <= 0;
                tick_counter <= 0;
                halfperiod_count <= 0;
                tick_count <= 0;
            end
            // Start sound generation
            busy <= 1;
            done <= 0;
            // Duration timer
            duration_counter <= sond_dur_ms_i;
            // Half period timer
            halfperiod_count <= half_period_us_i;
            // Tick counter
            tick_count <= 0;
        end
        else begin
            // Duration timer
            if (duration_counter > 0) begin
                duration_counter <= duration_counter - 1;
            end else begin
                busy <= 0;
                done <= 1;
            end
            // Half period timer
            if (halfperiod_counter > 0) begin
                halfperiod_counter <= halfperiod_counter - 1;
            end else begin
                strobe_counter <= strobe_counter + 1;
            end
            // Tick counter
            tick_count <= tick_count + 1;
            if (tick_count == PERIOD_US) begin
                tick_count <= 0;
                strobe_counter <= strobe_counter;
            end
        end
        // Soundwave signal generation
        if (busy && (strobe_counter == 0 || halfperiod_count == 0)) begin
            soundwave_o <= ~soundwave_o;
        end
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

parameter PERIOD_NS = PERIOD_US * CLOCK_HZ * 1000; // Convert period to nanoseconds

reg [31:0] period_counter;

always @(posedge clk) begin
    if (enable) begin
        if (nrst) begin
            period_counter <= PERIOD_NS;
        end else begin
            period_counter <= period_counter - 1;
        end
        if (period_counter == 0) begin
            strobe_o <= ~strobe_o;
            period_counter <= PERIOD_NS;
        end
    end
end

endmodule
