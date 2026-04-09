
always @(posedge clk or posedge reset) begin
    if (reset)
        begin
            pwm_duty_cycle <= 8'd0;  // Fan off by default
        end 
        else
        begin
            case(speed_control)
              3'd1 : pwm_duty_cycle <= 8'd64;  // Low speed (25% duty cycle)
              3'd2 : pwm_duty_cycle <= 8'd128; // Medium speed (50% duty cycle)
              3'd3 : pwm_duty_cycle <= 8'd192; // High speed (75% duty cycle)
              3'd4 : pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
            default :  pwm_duty_cycle <= 8'd255; // Full speed (100% duty cycle)
            endcase
        end
    end
