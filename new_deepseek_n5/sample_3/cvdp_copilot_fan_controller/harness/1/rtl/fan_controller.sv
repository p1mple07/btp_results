module fan_controller (
    input wire clk,                 // System clock
    input wire reset,               // Reset signal
    output reg fan_pwm_out,         // PWM output for fan control

    //APB signals
    input  wire         psel,       // Slave select
    input  wire         penable,    // Enable signal
    input  wire         pwrite,     // Write control
    input  wire [7:0]   paddr,      // Address bus
    input  wire [7:0]   pwdata,     // Write data bus
    output reg  [7:0]   prdata,     // Read data bus
    output reg          pready,      // Ready signal
    output reg          pslverr     // Slave error
)
// Initialize registers
integer temp_low = 0;
integer temp_med = 0;
integer temp_high = 0;
integer temp_adc = 0;

// Setup phase
always @* begin
    if (reset) begin
        temp_low = 0;
        temp_med = 0;
        temp_high = 0;
        temp_adc = 0;
        pready = 0;
        pslverr = 0;
        // Initialize all registers to default values
        TEMP_LOW = temp_low;
        TEMP_MED = temp_med;
        TEMP_HIGH = temp_high;
        temp_adc_in = temp_adc;
    end else begin
        // Decode address during setup phase
        if (psel && !penable) begin
            setup_phase = 1;
        end else begin
            setup_phase = 0;
        end
    end
end

// Access phase
always @* begin
    if (setup_phase && psel && penable) begin
        // Decode address
        case (paddr)
            0x0a: TEMP_LOW = pwdata;
            0x0b: TEMP_MED = pwdata;
            0x0c: TEMP_HIGH = pwdata;
            0x0f: temp_adc_in = pwdata;
            default: pslverr = 1;
        endcase
        pready = 1;
    else begin
        pready = 0;
    end
end

// Temperature based fan control
always @* begin
    integer duty_cycle;
    if (temp_adc_in < TEMP_LOW) begin
        duty_cycle = 64;
    else if (temp_adc_in <= TEMP_MED) begin
        duty_cycle = 128;
    else if (temp_adc_in <= TEMP_HIGH) begin
        duty_cycle = 192;
    else begin
        duty_cycle = 255;
    end
    // Update PWM signal based on duty cycle
    if (fan_pwm_out == (duty_cycle >> 8)) begin
        fan_pwm_out = 1;
    end
    // Reset counter
    fan_pwm_out = 0;
end

// PWM counter
always @* begin
    if (fan_pwm_out) begin
        prdata = 1;
    else begin
        prdata = 0;
    end
end

// Reset behavior
always @* begin
    if (reset) begin
        TEMP_LOW = 0;
        TEMP_MED = 0;
        TEMP_HIGH = 0;
        temp_adc_in = 0;
        pready = 0;
        pslverr = 0;
        fan_pwm_out = 0;
    end
end