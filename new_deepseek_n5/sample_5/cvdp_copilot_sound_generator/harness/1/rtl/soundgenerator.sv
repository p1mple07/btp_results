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

    // Internal parameters
    parameter DURATION = sond_dur_ms_i / 8;                // Convert to nanoseconds
    parameter HALF_PERIOD = half_period_us_i;              // Half period in microseconds

    // Internal state variables
    reg state = 0;                                         // 0: idle, 1: generating sound
    reg duration_counter = DURATION;                       // Duration counter in clock cycles
    reg halfperiod_counter = 0;                           // Half period counter in microseconds
    
    // Always block for duration tracking
    always @(posedge clk or posedge nrst) begin
        if (nrst) begin
            state = 0;
            duration_counter = DURATION;
            halfperiod_counter = 0;
            busy = 0;
        end else if (start) begin
            if (duration_counter > 0) begin
                duration_counter = duration_counter - 1;
            end
        end else if (finish) begin
            done = 1;
            busy = 0;
        end
    end

    // Always block for sound wave generation
    always @(posedge tickmicro) begin
        if (state == 1) begin
            if (halfperiod_counter > 0) begin
                halfperiod_counter = halfperiod_counter - 1;
            end else begin
                if (half_period == 0) begin
                    busy = 0;
                    soundwave_o = 0;
                end else begin
                    busy = 1;
                    soundwave_o = not soundwave_o;
                end
            end
        end
    end

    // Sound wave output control
    output wire [15:0] soundwave_o_value = soundwave_o;

    // Module outputs
    output soundwave_o = soundwave_o_value;
    output busy;
    output done;
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

    // Calculate delay based on input parameters
    reg DELAY = (PERIOD_US * 1000000) / CLOCK_HZ;          // Delay in clock cycles

    // Internal state variables
    reg state = 0;                                         // 0: idle, 1: strobing
    reg counter = 0;                                       // Counter for timing

    // Always block for strobe generation
    always @(posedge clock or posedge nrst) begin
        if (nrst) begin
            state = 0;
            counter = DELAY;
            strobe_o = 0;
        end else if (enable) begin
            if (counter > 0) begin
                counter = counter - 1;
            end else begin
                state = 1;
                strobe_o = 1;
                // After strobe pulse, wait for the delay to repeat
                if (counter == 0) begin
                    strobe_o = 0;
                end
            end
        end
    end
endmodule