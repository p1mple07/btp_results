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

// Duration counter setup
reg duration_counter = 0;
always @(posedge start) begin
    if (finish) begin
        busy = 0;
        done = 1;
        // Reset duration counter
        duration_counter = (sond_dur_ms_i << 1);
    end else if (posedge finish) begin
        busy = 1;
        duration_counter <= 0;
    end
end

// Sound wave counter setup
reg wave_counter = 0;
always @(posedge start) begin
    if (finish) begin
        busy = 0;
        done = 1;
        // Reset wave counter
        wave_counter = 0;
    end else if (posedge finish) begin
        busy = 1;
        wave_counter <= 0;
    end
end

// Tickmilli counter setup
reg tickmilli_counter = 0;
always @(posedge start) begin
    if (finish) begin
        busy = 0;
        done = 1;
        // Reset tickmilli counter
        tickmilli_counter = 1000; // 1ms = 1000 us
    end else if (posedge finish) begin
        busy = 1;
        tickmilli_counter <= 0;
    end
end

// tickmicro counter setup
reg tickmicro_counter = 0;
always @(posedge start) begin
    if (finish) begin
        busy = 0;
        done = 1;
        // Reset tickmicro counter
        tickmicro_counter = 1; // 1us
    end else if (posedge finish) begin
        busy = 1;
        tickmicro_counter <= 0;
    end
end

// Generate square wave
reg soundwave_state = 0;
always @(posedge start) begin
    if (finish) begin
        busy = 0;
        done = 1;
        soundwave_o = 0;
    end else if (posedge finish) begin
        busy = 1;
        soundwave_o = !soundwave_o;
    end
end

// Initialize on reset
always @* begin
    if (nrst) begin
        // Reset all counters and states
        duration_counter = 0;
        wave_counter = 0;
        tickmilli_counter = 0;
        tickmicro_counter = 0;
        soundwave_o = 0;
        busy = 0;
        done = 0;
    end
end

// Implement strob_gen modules
module TickMilli strob_gen (
    clk = clk,
    nrst = 0,
    enable = busy == 0
);
endmodule

module tickmicro strob_gen (
    clk = clk,
    nrst = 0,
    enable = busy == 0
);
endmodule

endmodule