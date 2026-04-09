module fan_controller (
    input  wire         clk,                 // System clock
    input  wire         reset,               // Asynchronous active high reset
    output reg          fan_pwm_out,         // PWM output for fan control

    // APB signals
    input  wire         psel,                // Slave select
    input  wire         penable,             // Enable signal (start of access phase)
    input  wire         pwrite,              // Write control (1 = write, 0 = read)
    input  wire [7:0]   paddr,               // Address bus
    input  wire [7:0]   pwdata,              // Write data bus
    output reg  [7:0]   prdata,              // Read data bus
    output reg          pready,              // Ready signal
    output reg          pslverr              // Slave error signal
);

  // Internal registers for temperature thresholds and sensor data
  reg [7:0] TEMP_LOW;      // Register at address 0x0a
  reg [7:0] TEMP_MED;      // Register at address 0x0b
  reg [7:0] TEMP_HIGH;     // Register at address 0x0c
  reg [7:0] temp_adc_in;   // Register at address 0x0f (simulated sensor data)

  // PWM generation registers
  reg [7:0] pwm_counter;   // Internal counter for PWM period
  reg [7:0] pwm_duty;      // Duty cycle threshold (determines PWM high time)

  // Optional state register for APB protocol (0: idle, 1: setup, 2: access)
  reg [1:0] apb_state;

  //--------------------------------------------------------------------------
  // APB Interface State Machine and Register Access
  //--------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      apb_state      <= 2'd0;
      pready         <= 1'b0;
      pslverr        <= 1'b0;
      // Initialize registers to default values.
      TEMP_LOW       <= 8'd0;
      TEMP_MED       <= 8'd0;
      TEMP_HIGH      <= 8'd0;
      temp_adc_in    <= 8'd0;
    end
    else begin
      // When not selected, clear status signals and return to idle.
      if (!psel) begin
        pready      <= 1'b0;
        pslverr     <= 1'b0;
        apb_state   <= 2'd0;
      end
      else begin
        if (penable) begin
          // Access phase: perform read or write based on paddr and pwrite.
          pready <= 1'b1;
          case (paddr)
            8'h0a: begin
              if (pwrite)
                TEMP_LOW <= pwdata;
              else
                prdata  <= TEMP_LOW;
            end
            8'h0b: begin
              if (pwrite)
                TEMP_MED <= pwdata;
              else
                prdata  <= TEMP_MED;
            end
            8'h0c: begin
              if (pwrite)
                TEMP_HIGH <= pwdata;
              else
                prdata  <= TEMP_HIGH;
            end
            8'h0f: begin
              if (pwrite)
                temp_adc_in <= pwdata;
              else
                prdata  <= temp_adc_in;
            end
            default: begin
              // Invalid address: assert slave error.
              pslverr <= 1'b1;
            end
          endcase
          apb_state <= 2'd2; // Mark access phase
        end
        else begin
          // Setup phase: psel asserted but penable not yet asserted.
          pready  <= 1'b0;
          pslverr <= 1'b0;
          apb_state <= 2'd1;
        end
      end
    end
  end

  //--------------------------------------------------------------------------
  // PWM Duty Cycle Determination Based on Temperature Thresholds
  //--------------------------------------------------------------------------
  // The PWM duty cycle is selected based on the sensor reading (temp_adc_in)
  // and the three threshold registers. The following duty cycles are used:
  //   • Below TEMP_LOW: 25% duty cycle  (counter threshold = 64)
  //   • Between TEMP_LOW and TEMP_MED: 50% duty cycle (threshold = 128)
  //   • Between TEMP_MED and TEMP_HIGH: 75% duty cycle (threshold = 192)
  //   • Above TEMP_HIGH: 100% duty cycle (threshold = 255)
  //
  // On reset, all registers are 0. To ensure the fan is disabled on reset,
  // we force pwm_duty to 0 when all registers are in their default state.
  //--------------------------------------------------------------------------
  always @(*) begin
    if ( (TEMP_LOW   == 8'd0) && (TEMP_MED   == 8'd0) &&
         (TEMP_HIGH  == 8'd0) && (temp_adc_in == 8'd0) )
      pwm_duty = 8'd0;
    else if (temp_adc_in < TEMP_LOW)
      pwm_duty = 8'd64;    // 25% duty cycle: high for 64 cycles out of 256
    else if (temp_adc_in < TEMP_MED)
      pwm_duty = 8'd128;   // 50% duty cycle: high for 128 cycles out of 256
    else if (temp_adc_in < TEMP_HIGH)
      pwm_duty = 8'd192;   // 75% duty cycle: high for 192 cycles out of 256
    else
      pwm_duty = 8'd255;   // 100% duty cycle: high for 255 cycles out of 256
  end

  //--------------------------------------------------------------------------
  // PWM Signal Generation
  //--------------------------------------------------------------------------
  // A 256-cycle period is used. The pwm_counter increments each clock cycle.
  // When pwm_counter reaches pwm_duty, it resets to 0. The PWM output is high
  // when pwm_counter is less than pwm_duty, and low otherwise.
  //--------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pwm_counter   <= 8'd0;
      fan_pwm_out   <= 1'b0;
    end
    else begin
      if (pwm_counter == pwm_duty)
        pwm_counter <= 8'd0;
      else
        pwm_counter <= pwm_counter + 1;
      fan_pwm_out <= (pwm_counter < pwm_duty) ? 1'b1 : 1'b0;
    end
  end

endmodule