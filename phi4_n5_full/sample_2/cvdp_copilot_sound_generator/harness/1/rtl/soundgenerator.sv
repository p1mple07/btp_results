module soundgenerator #(
	parameter CLOCK_HZ = 10_000_000
)(
	input wire clk,                                         // Input clock signal with frequency 10MHz
	input wire nrst,                                        // Active low asynchronous reset
	input wire start,                                       // Signal to indicate the start of the operation
	input wire finish,                                      // Signal to indicate the end of the operation
	input wire [15:0] sond_dur_ms_i,                        // Duration (in milliseconds) for which the sound should be generated
	input wire [15:0] half_period_us_i,                     // Half period of the desired soundwave frequency (in microseconds)
	output wire soundwave_o,                                // Generated soundwave output signal
	output wire busy,                                       // Indicates that the system is actively generating sound
	output wire done                                        // Indicates that the sound generation operation is complete
);

	// Internal state declaration: IDLE and SOUND
	typedef enum logic { IDLE, SOUND } state_t;
	state_t state, state_next;
	logic busy_prev;

	// Counters for duration and half-period timing
	logic [15:0] duration_count;
	logic [15:0] halfperiod_timer;

	// Internal register for soundwave output
	logic soundwave_reg;

	// Drive outputs based on state
	assign busy   = (state == SOUND);
	assign soundwave_o = (state == SOUND) ? soundwave_reg : 1'b0;
	// The done signal is asserted for one cycle when busy transitions from high to low.
	assign done   = (!state && busy_prev);

	// Instantiate strob_gen modules for millisecond and microsecond strobe pulses
	wire tickmilli_strobe;
	wire tickmicro_strobe;

	strob_gen #(
		.CLOCK_HZ(10_000_000),
		.PERIOD_US(1000)  // 1 ms pulse
	) tickmilli_inst (
		.clk(clk),
		.nrst(nrst),
		.enable(busy),       // Enable strobe generation when in SOUND state
		.strobe_o(tickmilli_strobe)
	);

	strob_gen #(
		.CLOCK_HZ(10_000_000),
		.PERIOD_US(1)       // 1 us pulse
	) tickmicro_inst (
		.clk(clk),
		.nrst(nrst),
		.enable(busy),
		.strobe_o(tickmicro_strobe)
	);

	// State register update (synchronous to clk, asynchronous reset)
	always_ff @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			state      <= IDLE;
			duration_count <= 16'd0;
			halfperiod_timer <= 16'd0;
			soundwave_reg <= 1'b0;
			busy_prev   <= 1'b0;
		end else begin
			busy_prev   <= busy;  // Capture previous busy for done detection
			state       <= state_next;
		end
	end

	// Next state logic and counter updates
	always_comb begin
		// Default: retain current state and no counter updates
		state_next = state;

		if (state == SOUND) begin
			// If finish is asserted or duration has elapsed, transition to IDLE
			if (finish || (duration_count == 16'd0))
				state_next = IDLE;
			else begin
				// On each 1ms strobe pulse, decrement the duration counter
				if (tickmilli_strobe)
					duration_count = duration_count - 16'd1;

				// On each 1us strobe pulse, update the half-period timer and toggle soundwave
				if (tickmicro_strobe) begin
					if (halfperiod_timer > 16'd0)
						halfperiod_timer = halfperiod_timer - 16'd1;
					else begin
						halfperiod_timer = half_period_us_i;
						soundwave_reg = ~soundwave_reg;
					end
				end
			end
		end else begin
			// In IDLE state, wait for start signal to begin sound generation
			if (start) begin
				state_next = SOUND;
				duration_count = sond_dur_ms_i;
				halfperiod_timer = half_period_us_i;
				soundwave_reg = 1'b0;
			end
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

	// Calculate delay based on clock frequency and desired period (in microseconds)
	// DELAY = (CLOCK_HZ / 1,000,000) * PERIOD_US
	localparam integer DELAY = CLOCK_HZ / 1_000_000 * PERIOD_US;

	reg [31:0] counter;  // Wide enough counter to cover the delay period

	always_ff @(posedge clk or negedge nrst) begin
		if (!nrst) begin
			counter   <= DELAY;
			strobe_o  <= 1'b0;
		end else begin
			// When disabled, reset the counter and strobe output
			if (!enable) begin
				counter   <= DELAY;
				strobe_o  <= 1'b0;
			end else begin
				if (counter == 32'd0) begin
					strobe_o  <= 1'b1;
					counter   <= DELAY;
				end else begin
					strobe_o  <= 1'b0;
					counter   <= counter - 32'd1;
				end
			end
		end
	end

endmodule