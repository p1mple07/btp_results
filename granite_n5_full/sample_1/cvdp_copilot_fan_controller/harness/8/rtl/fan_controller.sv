module fan_controller (
    input wire clk,                 // System clock
    input wire reset,               // Reset signal
    output reg fan_pwm_out,         // PWM output for fan control

    //APB Protocol States
    always @(posedge clk or posedge reset)
	begin
        if (reset)
        begin
            fan_pwm_out <= 1'b0;
        end
        else
        begin
            case(speed_control)
              3'd1 : fan_pwm_out <= (pwm_counter < 64)? 1'b1 : 1'b0; 
              3'd2 : fan_pwm_out <= (pwm_counter < 128)? 1'b1 : 1'b0; 
              3'd3 : fan_pwm_out <= (pwm_counter < 192)? 1'b1 : 1'b0; 
              3'd4 : fan_pwm_out <= (pwm_counter < 255)? 1'b1 : 1'b0; 
              default : fan_pwm_out <= 1'b0; 
            endcase

            pwm_counter <= (pwm_counter == 255)? 0 : (pwm_counter + 1);
        end
    end

    // Temperature sensor inputs
    reg [7:0]  temp_adc_in;   // Temperature sensor input (0-255)
  
    // Temperature thresholds
    reg [7:0] TEMP_LOW ;      // Low temperature threshold
    reg [7:0] TEMP_MED ;      // Medium temperature threshold
    reg [7:0] TEMP_HIGH;      // High temperature threshold
  
    // Speed control logic
    reg [2:0] speed_control;    //speed control bit 
    // Fan speed adjustment logic
    always @(posedge clk or posedge reset) begin
        if (reset)
        begin
            TEMP_LOW <= 8'd30;      // Set low temperature threshold
            TEMP_MED <= 8'd60;      // Set medium temperature threshold
            TEMP_HIGH<=8'd90;      // Set high temperature threshold
            speed_control <= 3'd0; // Set initial speed control value
        end 
        else
        begin
            case(speed_control)
              {3'd1, 3'd2} : speed_control <= 3'd0;  // Low and medium speeds
              {3'd3, 3'd4} : speed_control <= 3'd3;  // High and full speeds
              default :  speed_control <= 3'd0; // Full speed (100% duty cycle)
            endcase

        end
    end

    // PWM control
    reg [7:0] pwm_duty_cycle;    // Duty cycle (0-255)
    reg [7:0] pwm_counter;       // Counter for PWM generation
    wire [2:0] speed_control;    //speed control bit 

    // Fan speed adjustment logic
    always @(posedge clk or posedge reset) begin
        if (reset)
        begin
            pwm_duty_cycle <= 8'd0;  // Fan off by default
        end 
        else
        begin
            case(speed_control)
              {3'd1, 3'd2} : pwm_duty_cycle <= 8'd64;  // Low and medium speeds
              {3'd3, 3'd4} : pwm_duty_cycle <= 8'd255; // Full speeds
              default :  pwm_duty_cycle <= 8'd255; // Full speeds
            endcase

        end
    end

    // PWM generation logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_counter <= 8'd0;
            fan_pwm_out <= 1'b0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            fan_pwm_out <= (pwm_counter < pwm_duty_cycle)? 1'b1 : 1'b0;
        end
    end

endmodule