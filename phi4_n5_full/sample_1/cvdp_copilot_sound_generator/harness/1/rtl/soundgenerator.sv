module soundgenerator #(
	parameter  CLOCK_HZ = 10_000_000
)(
	input wire clk,                                         // Input clock (10 MHz)
	input wire nrst,                                        // Active-low asynchronous reset
	input wire start,                                       // Start signal for sound generation
	input wire finish,                                      // Finish signal to end operation
	input wire [15:0] sond_dur_ms_i,                        // Duration in milliseconds for sound generation
	input wire [15:0] half_period_us_i,                     // Half-period (in microseconds) for soundwave frequency
	output wire soundwave_o,                                // Generated soundwave output
	output wire busy,                                       // Indicates that the system is active (generating sound)
	output wire done                                        // Indicates that the sound generation operation is complete
);

	//---------------------------------------------------------------------
	// Instantiate strobe generators for millisecond and microsecond ticks.
	//---------------------------------------------------------------------
	wire tick_milli;  // Pulse every 1 ms (1000 µs)
	wire tick_micro;  // Pulse every 1 µs

	// TickMilli: strobe every 1000 µs (1 ms)
	strob_gen #(
		.CLOCK_HZ(10_000_000),
		.PERIOD_US(1000)
	) tickMilli (
		.clk   (clk),
		.nrst  (nrst),
		.enable(1'b1),
		.strobe_o(tick_milli)
	);

	// tickMicro: strobe every 1 µs
	strob_gen #(
		.CLOCK_HZ(10_000_000),
		.PERIOD_US(1)
	) tickMicro (
		.clk   (clk),
		.nrst  (nrst),
		.enable(1'b1),
		.strobe_o(tick_micro)
	);

	//---------------------------------------------------------------------
	// Internal registers and wires
	//---------------------------------------------------------------------
	// busy_reg indicates if sound generation is active.
	// done_reg generates a pulse when busy transitions from high to low.
	// soundwave_reg holds the current state of the square wave.
	// duration_counter counts the remaining milliseconds.
	// halfperiod_timer counts down microseconds for the half-period.
	reg busy_reg, done_reg, soundwave_reg;
	reg [15:0] duration_counter;
	reg [15:0] halfperiod_timer;
	reg busy_prev;  // To detect falling edge of busy

	// Output assignments: soundwave_o is active only when busy.
	assign soundwave_o = busy_reg ? soundwave_reg : 1'b0;
	assign busy         = busy_reg;
	assign done         = done_reg;

	//---------------------------------------------------------------------
	// Main sequential logic
	//---------------------------------------------------------------------
	always @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			// Asynchronous reset: clear all internal states.
			busy_reg     <= 1'b0;
			done_reg     <= 1'b0;
			busy_prev    <= 1'b0;
			duration_counter <= 16'd0;
			halfperiod_timer <= 16'd0;
			soundwave_reg <= 1'b0;
		end
		else begin
			// Save previous busy state for done pulse detection.
			busy_prev <= busy_reg;

			//-----------------------------------------------------------------
			// Check finish condition: if finish is asserted, immediately stop.
			//-----------------------------------------------------------------
			if (finish) begin
				busy_reg     <= 1'b0;
				duration_counter <= 16'd0;
				halfperiod_timer <= 16'd0;
				soundwave_reg <= 1'b0;
			end
			else begin
				//-----------------------------------------------------------------
				// If start is asserted, initialize the system and start generation.
				//-----------------------------------------------------------------
				if (start) begin
					busy_reg     <= 1'b1;
					duration_counter <= sond_dur_ms_i;
					halfperiod_timer <= half_period_us_i;
					soundwave_reg <= 1'b0;
				end

				//-----------------------------------------------------------------
				// Only update counters and generate soundwave when busy.
				//-----------------------------------------------------------------
				if (busy_reg) begin
					// Decrement the millisecond duration counter on each tick_milli.
					if (tick_milli) begin
						duration_counter <= duration_counter - 1;
					end

					// Decrement the half-period timer on each tick_micro.
					if (tick_micro) begin
						if (halfperiod_timer == 16'd0) begin
							// Toggle the soundwave output to generate a square wave.
							soundwave_reg <= ~soundwave_reg;
							// Reload the halfperiod timer.
							halfperiod_timer <= half_period_us_i;
						end
						else begin
							halfperiod_timer <= halfperiod_timer - 1;
						end
					end
				end
				else begin
					// Ensure soundwave output is 0 when not busy.
					soundwave_reg <= 1'b0;
				end

				//-----------------------------------------------------------------
				// Generate a done pulse when busy goes from high to low.
				//-----------------------------------------------------------------
				if (busy_prev && !busy_reg)
					done_reg <= 1'b1;
				else
					done_reg <= 1'b0;
			end
		end
	end

endmodule

//---------------------------------------------------------------------
// strob_gen module: Generates a periodic strobe signal.
//---------------------------------------------------------------------
module strob_gen #(
	parameter CLOCK_HZ	= 10_000_000,
	parameter PERIOD_US	= 100
)(
	input wire  clk,
	input wire  nrst,
	input wire  enable,
	output reg  strobe_o
);

	//---------------------------------------------------------------------
	// Calculate the delay value (number of clock cycles) for the strobe.
	// DELAY = (CLOCK_HZ / 1,000,000) * PERIOD_US
	//---------------------------------------------------------------------
	localparam integer DELAY = (CLOCK_HZ / 1_000_000) * PERIOD_US;

	reg [31:0] count;

	always @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			count     <= DELAY;
			strobe_o  <= 1'b0;
		end
		else begin
			if (!enable) begin
				// When disabled, reset the counter and suppress strobe.
				count     <= DELAY;
				strobe_o  <= 1'b0;
			end
			else begin
				if (count == 32'd0) begin
					// Pulse strobe high for one clock cycle.
					strobe_o <= 1'b1;
					count    <= DELAY;
				end
				else begin
					strobe_o <= 1'b0;
					count    <= count - 1;
				end
			end
		end
	end

endmodule