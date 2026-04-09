module fan_controller (
    input wire clk,                 // System clock
    input wire reset,               // Reset signal
    output reg fan_pwm_out,         // PWM output for fan control

    // APB signals
    input  wire         psel,       // Slave select
    input  wire         penable,    // Enable signal
    input  wire         pwrite,     // Write control
    input  wire [7:0]   paddr,      // Address bus
    input  wire [7:0]   pwdata,     // Write data bus
    output reg  [7:0]   prdata,     // Read data bus
    output reg          pready,      // Ready signal
    output reg          pslverr     // Slave error
);

// Internal registers
reg [3:0] temp_low, temp_med, temp_high, temp_adc_in;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        temp_low <= 0;
        temp_med <= 0;
        temp_high <= 0;
        temp_adc_in <= 0;
        fan_pwm_out <= 0;
        pslverr <= 0;
    end else begin
        // Read from temperature registers
        temp_low = regread(TEMP_LOW);
        temp_med = regread(TEMP_MED);
        temp_high = regread(TEMP_HIGH);
        temp_adc_in = regread(temp_adc_in);

        // Set fan speed based on temperature
        if (temp_adc_in < TEMP_LOW) begin
            fan_pwm_out <= 0;
        end else if (temp_adc_in < TEMP_MED) begin
            fan_pwm_out <= 1;
        end else if (temp_adc_in < TEMP_HIGH) begin
            fan_pwm_out <= 1;
        end else begin
            fan_pwm_out <= 1;
        end
    end
end

// APB interface implementation
always @(posedge clk or negedge reset) begin
    if (!psel || !penable) begin
        // Not in access phase
        pready <= 0;
        pslverr <= 0;
    end else begin
        // Enter access phase
        pready <= 1;
        // Assign the values for APB
        assign paddr = 8'h00;
        assign pwdata = 8'b00000000;
        assign prdata = 8'b00000000;
        assign pready = 1;
        assign pslverr = 0;
    end
end

endmodule
