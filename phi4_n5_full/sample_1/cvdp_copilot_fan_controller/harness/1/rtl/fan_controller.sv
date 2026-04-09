module fan_controller (
    input  wire         clk,                 // System clock
    input  wire         reset,               // Reset signal
    output reg          fan_pwm_out,         // PWM output for fan control

    // APB signals
    input  wire         psel,                // Slave select
    input  wire         penable,             // Enable signal
    input  wire         pwrite,              // Write control
    input  wire [7:0]   paddr,               // Address bus
    input  wire [7:0]   pwdata,              // Write data bus
    output reg  [7:0]   prdata,              // Read data bus
    output reg          pready,              // Ready signal
    output reg          pslverr              // Slave error
);

  //-------------------------------------------------------------------------
  // Internal registers for temperature thresholds and sensor data
  //-------------------------------------------------------------------------
  reg [7:0] TEMP_LOW;    // Maximum temperature for low category
  reg [7:0] TEMP_MED;    // Maximum temperature for medium category
  reg [7:0] TEMP_HIGH;   // Maximum temperature for high category
  reg [7:0] temp_adc_in; // Simulated ADC input for current temperature

  //-------------------------------------------------------------------------
  // PWM counter for generating PWM signal
  // The counter period is fixed at 256 clock cycles.
  //-------------------------------------------------------------------------
  reg [7:0] pwm_counter;

  //-------------------------------------------------------------------------
  // APB Interface: Implement AMBA APB protocol with setup and access phases.
  // - Setup Phase: psel is asserted while penable is deasserted.
  // - Access Phase: Both psel and penable are asserted.
  // During the access phase, the module performs read/write operations
  // based on paddr and asserts pready upon completion. If an invalid address
  // is accessed, pslverr is asserted.
  //-------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all registers and status signals to default values.
      TEMP_LOW    <= 8'd0;
      TEMP_MED    <= 8'd0;
      TEMP_HIGH   <= 8'd0;
      temp_adc_in <= 8'd0;
      pready      <= 1'b0;
      pslverr     <= 1'b0;
    end else begin
      // Default: clear status signals.
      pready   <= 1'b0;
      pslverr  <= 1'b0;

      if (psel) begin
        if (penable) begin
          // Access phase: perform the requested operation.
          case (paddr)
            8'h0a: begin // TEMP_LOW register
              if (pwrite)
                TEMP_LOW <= pwdata;
              else
                prdata  <= TEMP_LOW;
            end
            8'h0b: begin // TEMP_MED register
              if (pwrite)
                TEMP_MED <= pwdata;
              else
                prdata  <= TEMP_MED;
            end
            8'h0c: begin // TEMP_HIGH register
              if (pwrite)
                TEMP_HIGH <= pwdata;
              else
                prdata  <= TEMP_HIGH;
            end
            8'h0f: begin // temp_adc_in register (simulated sensor data)
              if (pwrite)
                temp_adc_in <= pwdata;
              else
                prdata  <= temp_adc_in;
            end
            default: begin
              // Invalid address access; assert error signal.
              pslverr <= 1'b1;
            end
          endcase
          pready <= 1'b1; // Indicate transaction complete.
        end
        // Setup phase: psel asserted but penable not asserted; no operation.
      end
      // If module is not selected (psel=0), status signals remain cleared.
    end
  end

  //-------------------------------------------------------------------------
  // PWM Signal Generation: Dynamically adjust fan speed based on temperature.
  // Duty cycle selection based on temp_adc_in and threshold registers:
  //   • Below TEMP_LOW: 25% duty cycle (counter < 64)
  //   • Between TEMP_LOW and TEMP_MED: 50% duty cycle (counter < 128)
  //   • Between TEMP_MED and TEMP_HIGH: 75% duty cycle (counter < 192)
  //   • Above TEMP_HIGH: 100% duty cycle (counter < 255)
  // The PWM counter runs from 0 to 255 (256 clock cycles period).
  //-------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pwm_counter   <= 8'd0;
      fan_pwm_out   <= 1'b0;
    end else begin
      // Update PWM counter; reset to 0 after reaching 255.
      if (pwm_counter == 8'd255)
        pwm_counter <= 8'd0;
      else
        pwm_counter <= pwm_counter + 1;

      // Generate PWM signal based on current temperature reading.
      if (temp_adc_in < TEMP_LOW)
        fan_pwm_out <= (pwm_counter < 8'd64);
      else if (temp_adc_in < TEMP_MED)
        fan_pwm_out <= (pwm_counter < 8'd128);
      else if (temp_adc_in < TEMP_HIGH)
        fan_pwm_out <= (pwm_counter < 8'd192);
      else
        fan_pwm_out <= (pwm_counter < 8'd255);
    end
  end

endmodule