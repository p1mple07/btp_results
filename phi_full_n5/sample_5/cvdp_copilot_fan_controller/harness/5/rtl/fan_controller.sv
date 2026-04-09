
// Corrected PWM control logic with matching bit widths
always @(posedge clk or posedge reset) begin
    if (reset)
    begin
        pwm_duty_cycle <= 8'd0;  // Fan off by default
    end 
    else
    begin
        case(speed_control)
          1 : pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle)
          2 : pwm_duty_cycle <= 8'd128; // Medium speed (50% duty cycle)
          3 : pwm_duty_cycle <= 8'd192; // High speed (75% duty cycle)
          4 : pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
        default :  pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
        endcase
    end
end

// Corrected PWM generation logic with matching bit widths
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pwm_counter <= 8'd0;
        fan_pwm_out <= 1'b0;
    end else begin
        pwm_counter <= pwm_counter + 1;
        fan_pwm_out <= (pwm_counter < pwm_duty_cycle) ? 1'b1 : 1'b0;
    end
end
