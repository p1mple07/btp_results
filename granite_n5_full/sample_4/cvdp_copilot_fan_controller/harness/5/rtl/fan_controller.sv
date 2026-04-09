assign fan_pwm_out = (pwm_counter < pwm_duty_cycle)? 1'b1 : 1'b0;

assign fan_pwm_out = (pwm_counter < pwm_duty_cycle)? 1'b1 : 1'b0;

assign fan_pwm_out = (pwm_counter < pwm_duty_cycle)? 1'b1 : 1'b0;

always @* begin
       if (pwm_counter < pwm_duty_cycle) begin
           fan_pwm_out <= 1'b1;
       end else begin
           fan_pwm_out <= 1'b0;
       end
   end