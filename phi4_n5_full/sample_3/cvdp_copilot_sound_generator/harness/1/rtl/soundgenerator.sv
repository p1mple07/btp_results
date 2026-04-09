module soundgenerator #(
	parameter CLOCK_HZ = 10_000_000
)(
	input wire clk,                                         // input clock signal with frequency 10 MHz
	input wire nrst,                                        // active low asynchronous reset.
	
	input wire start,                                       // indicate the start of the operation.
	input wire finish,                                      // indicate the end of operation.
	input wire [15:0] sond_dur_ms_i,                        // duration (in milliseconds) for which the sound should be generated
	input wire [15:0] half_period_us_i,                     // half period of the soundwave in microseconds
	
	output wire soundwave_o,                                // generated soundwave output (square wave)
	output wire busy,                                       // indicates the system is actively generating sound
	output wire done                                        // indicates that the sound generation operation is complete
);

	// Internal strobe signals from timing generators
	wire ms_strobe;  // 1ms strobe pulse
	wire us_strobe;  // 1us strobe pulse

	// Instantiate the millisecond strobe generator (TickMilli)
	strob_gen #(
		.CLOCK_HZ(CLOCK_HZ),
		.PERIOD_US(1000)  // 1 ms = 1000 µs
	) ms_strob_gen_inst (
		.clk(clk),
		.nrst(nrst),
		.enable(busy),  // enable strobe generation only when busy
		.strobe_o(ms_strobe)
	);

	// Instantiate the microsecond strobe generator (TickMicro)
	strob_gen #(
		.CLOCK_HZ(CLOCK_HZ),
		.PERIOD_US(1)   // 1 µs
	) us_strob_gen_inst (
		.clk(clk),
		.nrst(nrst),
		.enable(busy),  // enable strobe generation only when busy
		.strobe_o(us_strobe)
	);

	// Internal registers for timing and signal generation
	reg [15:0] duration_counter;   // counts remaining milliseconds
	reg [15:0] halfperiod_counter; // counts microseconds for the half period
	reg soundwave_reg;             // internal soundwave signal register
	reg busy_reg;                  // internal busy flag
	reg done_reg;                  // one-cycle done signal

	// Drive outputs: soundwave output is active only when busy; busy and done pass through
	assign soundwave_o = busy_reg ? soundwave_reg : 1'b0;
	assign busy         = busy_reg;
	assign done         = done_reg;

	// Main state and counter logic
	always @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			// Reset all internal states
			duration_counter   <= 16'd0;
			halfperiod_counter <= 16'd0;
			soundwave_reg      <= 1'b0;
			busy_reg           <= 1'b0;
			done_reg           <= 1'b0;
		end else begin
			// When start is asserted and system is idle, load counters and start generation.
			if (start && !busy_reg) begin
				duration_counter   <= sond_dur_ms_i;
				halfperiod_counter <= half_period_us_i;
				soundwave_reg      <= 1'b0;
				busy_reg           <= 1'b1;
			end

			// If finish is asserted, immediately stop generation.
			if (finish) begin
				busy_reg      <= 1'b0;
				done_reg      <= 1'b1;
				duration_counter   <= 16'd0;
				halfperiod_counter <= 16'd0;
				soundwave_reg      <= 1'b0;
			end else if (busy_reg) begin
				// On every 1ms strobe pulse, decrement the duration counter.
				if (ms_strobe) begin
					if (duration_counter == 16'd1)
						duration_counter <= 16'd0;
					else
						duration_counter <= duration_counter - 16'd1;
				end

				// On every 1us strobe pulse, decrement the half-period counter.
				// When it reaches zero, toggle the soundwave signal and reload the counter.
				if (us_strobe) begin
					halfperiod_counter <= halfperiod_counter - 16'd1;
					if (halfperiod_counter == 16'd0) begin
						soundwave_reg      <= ~soundwave_reg;
						halfperiod_counter <= half_period_us_i;
					end
				end

				// If the duration counter has expired, stop generation and assert done.
				if (duration_counter == 16'd0) begin
					busy_reg <= 1'b0;
					done_reg <= 1'b1;
				end
			end
			// When not busy, no action is taken.
		end
	end

endmodule

module strob_gen #(
	parameter CLOCK_HZ = 10_000_000,
	parameter PERIOD_US = 100
)(
	input wire clk,
	input wire nrst,
	input wire enable,
	output reg strobe_o
);

	// Calculate delay in clock cycles based on clock frequency and desired period.
	localparam integer DELAY = (CLOCK_HZ / 1_000_000) * PERIOD_US;

	reg [31:0] counter;

	always @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			counter   <= DELAY;
			strobe_o  <= 1'b0;
		end else begin
			// When enable is low, reset counter and suppress strobe output.
			if (!enable) begin
				counter   <= DELAY;
				strobe_o  <= 1'b0;
			end else begin
				if (counter == 1) begin
					strobe_o <= 1'b1;
					counter  <= DELAY;
				end else begin
					strobe_o <= 1'b0;
					counter  <= counter - 1;
				end
			end
		end
	end

endmodule