module fan_controller (
    input  wire clk,                 // System clock
    input  wire reset,               // Reset signal
    output reg  fan_pwm_out,         // PWM output for fan control

    // APB signals
    input  wire         psel,       // Slave select
    input  wire         penable,    // Enable signal
    input  wire         pwrite,     // Write control (1 = write, 0 = read)
    input  wire [7:0]   paddr,      // Address bus
    input  wire [7:0]   pwdata,     // Write data bus
    output reg  [7:0]   prdata,     // Read data bus
    output reg          pready,     // Ready signal
    output reg          pslverr     // Slave error
);

  // Internal registers for temperature thresholds and sensor data
  reg [7:0] TEMP_LOW;
  reg [7:0] TEMP_MED;
  reg [7:0] TEMP_HIGH;
  reg [7:0] temp_adc_in;

  // PWM counter for PWM generation (period = 256 clock cycles)
  reg [7:0] pwm_counter;

  // APB interface process
  // Implements the AMBA APB protocol: Setup phase when psel is asserted but penable is deasserted,
  // and Access phase when both psel and penable are asserted.
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all registers to default values (0)
      TEMP_LOW    <= 8'd0;
      TEMP_MED    <= 8'd0;
      TEMP_HIGH   <= 8'd0;
      temp_adc_in <= 8'd0;
      pready      <= 1'b0;
      pslverr     <= 1'b0;
    end else begin
      // When not selected, clear status signals.
      if (!psel) begin
         pready  <= 1'b0;
         pslverr <= 1'b0;
      end else begin
         if (penable) begin
           // Access phase: perform read or write operation based on paddr.
           case (paddr)
             8'h0a: begin // TEMP_LOW register
               if (pwrite)
                 TEMP_LOW <= pwdata;
               prdata <= TEMP_LOW;
             end
             8'h0b: begin // TEMP_MED register
               if (pwrite)
                 TEMP_MED <= pwdata;
               prdata <= TEMP_MED;
             end
             8'h0c: begin // TEMP_HIGH register
               if (pwrite)
                 TEMP_HIGH <= pwdata;
               prdata <= TEMP_HIGH;
             end
             8'h0f: begin // temp_adc_in register (simulated sensor data)
               if (pwrite)
                 temp_adc_in <= pwdata;
               prdata <= temp_adc_in;
             end
             default: begin
               // Invalid address: assert slave error.
               pslverr <= 1'b1;
               prdata  <= 8'd0;
             end
           endcase
           // Assert ready signal during the access phase.
           pready <= 1'b1;
         end else begin
           // Setup phase: psel is asserted but penable is not.
           pready  <= 1'b0;
           pslverr <= 1'b0;
         end
      end
    end
  end

  // PWM signal generation process
  // The PWM duty cycle is determined by comparing the sensor reading (temp_adc_in)
  // with the threshold registers (TEMP_LOW, TEMP_MED, TEMP_HIGH).
  // Duty cycle thresholds:
  // - Below TEMP_LOW: 25% duty cycle (active for 64 cycles)
  // - Between TEMP_LOW and TEMP_MED: 50% duty cycle (active for 128 cycles)
  // - Between TEMP_MED and TEMP_HIGH: 75% duty cycle (active for 192 cycles)
  // - Above TEMP_HIGH: 100% duty cycle (active for 255 cycles)
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pwm_counter  <= 8'd0;
      fan_pwm_out  <= 1'b0;
    end else begin
      // Increment the PWM counter; reset when it reaches 255 (period = 256 cycles).
      if (pwm_counter == 8'd255)
        pwm_counter <= 8'd0;
      else
        pwm_counter <= pwm_counter + 1;

      // Determine the active portion of the PWM cycle based on temperature thresholds.
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