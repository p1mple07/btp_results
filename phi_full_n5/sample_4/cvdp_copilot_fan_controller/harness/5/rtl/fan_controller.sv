
module fan_controller (
    // ... (other code remains unchanged)

    reg [7:0] pwdata; // Use 8-bit data bus

    // ... (other code remains unchanged)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwdata <= 8'd0; // Use 8-bit assignment
            // ... (other reset assignments remain unchanged)
        end else begin
            // ... (other code remains unchanged)

            // Corrected PWM generation logic
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    pwm_counter <= 8'd0;
                    fan_pwm_out <= 1'b0;
                end else begin
                    pwm_counter <= pwdata + 1; // Increment by 1, assuming pwdata is 8-bit
                    fan_pwm_out <= (pwm_counter < pwdata) ? 1'b1 : 1'b0;
                end
            end
        end
    end

    // ... (other code remains unchanged)

    assign speed_control = (temp_adc_in < TEMP_LOW ? 1 : 
                           (temp_adc_in < TEMP_MED ? 2 : 
                           (temp_adc_in < TEMP_HIGH ? 3 : 4)));

    // ... (other code remains unchanged)

endmodule
