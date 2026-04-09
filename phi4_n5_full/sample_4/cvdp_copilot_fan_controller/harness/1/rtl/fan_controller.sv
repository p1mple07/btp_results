module fan_controller (
    input  wire         clk,       // System clock
    input  wire         reset,     // Asynchronous active high reset
    output reg          fan_pwm_out, // PWM output for fan control

    // APB signals
    input  wire         psel,      // Slave select
    input  wire         penable,   // Enable signal for access phase
    input  wire         pwrite,    // Write control (1 = write, 0 = read)
    input  wire [7:0]   paddr,     // Address bus
    input  wire [7:0]   pwdata,    // Write data bus
    output reg  [7:0]   prdata,    // Read data bus
    output reg          pready,    // Ready signal
    output reg          pslverr    // Slave error signal
);

  // Internal registers for temperature thresholds and ADC sensor data
  reg [7:0] TEMP_LOW;
  reg [7:0] TEMP_MED;
  reg [7:0] TEMP_HIGH;
  reg [7:0] temp_adc_in;

  // PWM generator registers
  reg [7:0] pwm_cnt;   // 8-bit counter for PWM period (0 to 255)
  reg [7:0] pwm_duty;  // Duty cycle threshold (number of cycles high)

  //--------------------------------------------------------------------------
  // APB Interface: Handle read/write operations and state transitions
  //--------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Initialize registers with default values
      TEMP_LOW      <= 8'd50;    // Default low threshold
      TEMP_MED      <= 8'd100;   // Default medium threshold
      TEMP_HIGH     <= 8'd150;   // Default high threshold
      temp_adc_in   <= 8'd0;     // Default sensor reading
      prdata        <= 8'd0;
      pready        <= 1'b0;
      pslverr       <= 1'b0;
    end
    else begin
      // Default: clear status signals if not selected
      pready        = 1'b0;
      pslverr       = 1'b0;

      if (psel) begin  // Only process when selected
        if (penable) begin  // Access phase
          pready = 1'b1;    // Assert ready signal
          if (pwrite) begin
            // Write operation: update register based on address
            case(paddr)
              8'h0a: TEMP_LOW      <= pwdata;
              8'h0b: TEMP_MED      <= pwdata;
              8'h0c: TEMP_HIGH     <= pwdata;
              8'h0f: temp_adc_in   <= pwdata;
              default: pslverr = 1'b1;  // Invalid address error
            endcase
          end
          else begin
            // Read operation: return data from register based on address
            case(paddr)
              8'h0a: prdata <= TEMP_LOW;
              8'h0b: prdata <= TEMP_MED;
              8'h0c: prdata <= TEMP_HIGH;
              8'h0f: prdata <= temp_adc_in;
              default: pslverr = 1'b1;  // Invalid address error
            endcase
          end
        end
        // Setup phase (penable low): no operation; status signals remain cleared.
      end
      // If psel is low, pready and pslverr remain 0.
    end
  end

  //--------------------------------------------------------------------------
  // PWM Generator: Generate fan control PWM signal based on temperature
  //--------------------------------------------------------------------------
  // PWM counter: counts from 0 to 255 (period = 256 clock cycles)
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pwm_cnt <= 8'd0;
    end
    else begin
      pwm_cnt <= pwm_cnt + 1;
      if (pwm_cnt == 8'd255)
        pwm_cnt <= 8'd0;
    end
  end

  // Compute duty cycle based on sensor reading and thresholds.
  // Duty cycle mapping:
  //   Below TEMP_LOW:    25% duty cycle (high for 64 cycles)
  //   Between TEMP_LOW and TEMP_MED: 50% duty cycle (high for 128 cycles)
  //   Between TEMP_MED and TEMP_HIGH: 75% duty cycle (high for 192 cycles)
  //   Above TEMP_HIGH:   100% duty cycle (high for 255 cycles)
  always @(*) begin
    if (temp_adc_in < TEMP_LOW)
      pwm_duty = 8'd64;
    else if (temp_adc_in < TEMP_MED)
      pwm_duty = 8'd128;
    else if (temp_adc_in < TEMP_HIGH)
      pwm_duty = 8'd192;
    else
      pwm_duty = 8'd255;
  end

  // Generate PWM output: fan_pwm_out is high when pwm_cnt is less than pwm_duty.
  always @(*) begin
    fan_pwm_out = (pwm_cnt < pwm_duty) ? 1'b1 : 1'b0;
  end

endmodule