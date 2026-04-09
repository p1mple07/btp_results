// Temperature thresholds and internal counter for PWM
reg [7:0] TEMP_LOW = 0x0a;
reg [7:0] TEMP_MED = 0x0b;
reg [7:0] TEMP_HIGH = 0x0c;
reg [7:0] temp_adc_in_data;
reg [7:0] pwm_counter;

// Fan speed duty cycle
reg [7:0] fan_pwm_duty_cycle;

// State machine for APB interface
reg [2:0] apb_state;

// Module implementation
always @(posedge clk) begin
    case (apb_state)
        0: begin
            // Setup Phase
            if (psel && !penable) begin
                // Perform address decoding (not shown here, but required for setup)
            end
        end
        1: begin
            // Access Phase
            if (psel && penable) begin
                // Perform read or write operation
                if (pwrite) begin
                    // Write operation
                    if (paddr == TEMP_LOW) begin
                        temp_adc_in_data = pwdata;
                    end else if (paddr == TEMP_MED) begin
                        temp_adc_in_data = pwdata;
                    end else if (paddr == TEMP_HIGH) begin
                        temp_adc_in_data = pwdata;
                    end else begin
                        pslverr = 1; // Invalid address
                    end
                end else if (paddr == temp_adc_in_data's address) begin
                    // Read operation
                    prdata = temp_adc_in_data;
                    pready = 1;
                end else begin
                    pslverr = 1; // Invalid address
                end
                pready = 1;
            end
        end
        default: begin
            // Reset behavior
            if (reset) begin
                TEMP_LOW = 0x0a;
                TEMP_MED = 0x0b;
                TEMP_HIGH = 0x0c;
                temp_adc_in_data = 0;
                fan_pwm_duty_cycle = 0;
                pready = 0;
                pslverr = 0;
            end
        end
    endcase
end

// Temperature-based fan speed control
always @(posedge clk) begin
    case (temp_adc_in_data)
        0: begin
            fan_pwm_duty_cycle = 64; // Low speed
        end
        127: begin
            fan_pwm_duty_cycle = 128; // Medium speed
        end
        255: begin
            fan_pwm_duty_cycle = 192; // High speed
        end
        default: begin
            fan_pwm_duty_cycle = 0; // Disabled
        end
    endcase
end

// PWM signal generation
always @(posedge clk) begin
    if (pready) begin
        if (fan_pwm_duty_cycle != pwm_counter) begin
            pwm_counter <= fan_pwm_duty_cycle;
            fan_pwm_out = pwm_counter;
        end
        else begin
            fan_pwm_out = 0;
        end
    end
end

endmodule
