// Register definitions
reg [7:0] TEMP_LOW, TEMP_MED, TEMP_HIGH, temp_adc_in;

// State machine variables
reg [2:0] state;
reg [7:0] pwm_duty_cycle;

// Implementation of fan_controller module
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 0;
        TEMP_LOW <= 0x0a;
        TEMP_MED <= 0x0b;
        TEMP_HIGH <= 0x0c;
        temp_adc_in <= 0x0f;
        fan_pwm_out <= 0;
        prdata <= 0;
        pready <= 0;
        pslverr <= 0;
    end else begin
        case (state)
            0: begin // Setup phase
                if (psel) begin
                    penable <= 1;
                    state <= 1;
                end else begin
                    pslverr <= 1;
                end
            end
            1: begin // Access phase
                if (pwrite) begin
                    if (paddr == TEMP_LOW) begin
                        TEMP_LOW <= pwdata;
                    end else if (paddr == TEMP_MED) begin
                        TEMP_MED <= pwdata;
                    end else if (paddr == TEMP_HIGH) begin
                        TEMP_HIGH <= pwdata;
                    end else begin
                        pslverr <= 1;
                    end
                    prdata <= paddr;
                    pready <= 1;
                end else begin
                    prdata <= paddr;
                    pready <= 1;
                end
            end
            2: begin // Read operation
                prdata <= paddr;
                pready <= 1;
            end
            3: begin // Write operation
                if (paddr == TEMP_LOW) begin
                    TEMP_LOW <= pwdata;
                end else if (paddr == TEMP_MED) begin
                    TEMP_MED <= pwdata;
                end else if (paddr == TEMP_HIGH) begin
                    TEMP_HIGH <= pwdata;
                end else begin
                    pslverr <= 1;
                end
                pready <= 1;
            end
            default: state <= 0;
        endcase
    end
end

// PWM generation based on temperature readings
always @(posedge clk) begin
    if (penable) begin
        case (temp_adc_in)
            0: pwm_duty_cycle <= 64;
            64: pwm_duty_cycle <= 192;
            192: pwm_duty_cycle <= 255;
            default: pwm_duty_cycle <= 0;
        endcase
        fan_pwm_out <= pwm_duty_cycle;
    end
end

// Reset behavior
always @(posedge clk) begin
    if (reset) begin
        fan_pwm_out <= 0;
        pwm_duty_cycle <= 0;
        TEMP_LOW <= 0x0a;
        TEMP_MED <= 0x0b;
        TEMP_HIGH <= 0x0c;
        temp_adc_in <= 0x0f;
        pready <= 0;
        pslverr <= 0;
    end
end

// Error handling for invalid APB addresses
always @(pwrite, paddr) begin
    if (paddr > 255 || paddr < 0) begin
        pslverr <= 1;
    end
end
