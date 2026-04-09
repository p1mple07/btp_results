// Temperature threshold registers
reg [7:0] TEMP_LOW, TEMP_MED, TEMP_HIGH;

// Simulated ADC input register
reg [7:0] temp_adc_in;

// PWM control signal
reg [7:0] pwm_counter;

// Fan speed control
parameter DUTY_CYCLE_LOW = 64;
parameter DUTY_CYCLE_MED = 128;
parameter DUTY_CYCLE_HIGH = 192;
parameter DUTY_CYCLE_FULL = 255;

// Default values
initial begin
    TEMP_LOW = 30; // Example low temperature threshold
    TEMP_MED = 45; // Example medium temperature threshold
    TEMP_HIGH = 60; // Example high temperature threshold
    pwm_counter = 0;
end

// State machine for APB interface
always @(posedge clk) begin
    if (reset) begin
        psel <= 0;
        penable <= 0;
        pwrite <= 0;
        paddr <= 0;
        pwdata <= 0;
        prdata <= 0;
        pready <= 0;
        pslverr <= 0;
        fan_pwm_out <= 0;
    end else begin
        case (psel)
            1: begin
                if (penable) begin
                    switch (paddr) begin
                        case 8'h0A: TEMP_LOW <= pwdata;
                        case 8'h0B: TEMP_MED <= pwdata;
                        case 8'h0C: TEMP_HIGH <= pwdata;
                        default: pslverr <= 1;
                    end
                    pready <= 1;
                end
            end
            0: begin
                pslverr <= 0;
                pready <= 0;
            end
        endcase
    end
end

// Temperature-based fan speed control
always @(posedge clk) begin
    if (pslverr == 0) begin
        case (temp_adc_in)
            8'h00: fan_pwm_out <= DUTY_CYCLE_LOW;
            8'h01: fan_pwm_out <= DUTY_CYCLE_LOW;
            8'h02: fan_pwm_out <= DUTY_CYCLE_MED;
            8'h03: fan_pwm_out <= DUTY_CYCLE_MED;
            8'h04: fan_pwm_out <= DUTY_CYCLE_HIGH;
            8'h05: fan_pwm_out <= DUTY_CYCLE_HIGH;
            default: fan_pwm_out <= DUTY_CYCLE_FULL;
        endcase
    end
end

// PWM signal generation
always @(posedge clk) begin
    if (pslverr == 0) begin
        case (fan_pwm_out)
            8'h00: pwm_counter <= DUTY_CYCLE_LOW;
            8'h01: pwm_counter <= DUTY_CYCLE_LOW;
            8'h02: pwm_counter <= DUTY_CYCLE_MED;
            8'h03: pwm_counter <= DUTY_CYCLE_MED;
            8'h04: pwm_counter <= DUTY_CYCLE_HIGH;
            8'h05: pwm_counter <= DUTY_CYCLE_HIGH;
            8'hFF: pwm_counter <= DUTY_CYCLE_FULL;
            default: pwm_counter <= 0;
        endcase
    end
end

// Output the PWM signal
assign fan_pwm_out = pwm_counter;

endmodule
