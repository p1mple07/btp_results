module fan_controller (
    input wire clk,
    input wire reset,
    output reg fan_pwm_out,

    input  wire psel,
    input  wire penable,
    input  wire pwrite,
    input  wire [7:0] paddr,
    input  wire [7:0] pwdata,
    output reg [7:0] prdata,
    output reg pready,
    output reg pslverr
);

reg [7:0] temp_adc_in;
reg [3:0] temp_low, temp_med, temp_high;

always @(posedge clk) begin
  if (reset) begin
    temp_adc_in <= 3'd0;
    temp_low <= 8'h00;
    temp_med <= 8'h08;
    temp_high <= 8'hF0;
  end else begin
    temp_adc_in <= temp_adc_in[7:0];
  end

  temp_low <= 8'h00;
  temp_med <= 8'h08;
  temp_high <= 8'hF0;

  // Now read from temp registers
  temp_adc_in = temp_adc_in[3:0];

  // Determine duty cycle
  if (temp_adc_in <= temp_low) begin
    fan_speed = 25;
  end else if (temp_adc_in <= temp_med) begin
    fan_speed = 50;
  end else if (temp_adc_in <= temp_high) begin
    fan_speed = 75;
  end else begin
    fan_speed = 100;
  end

  // Calculate the number of clock cycles for the PWM
  // Duty cycle percentage: 25% => 64 cycles (half of 128), 50% => 128, 75% => 192, 100% => 255
  // But we can output 1 for full cycle, 0 otherwise.
  if (fan_speed == 25) begin
    fan_pwm_out = 1;
  end else if (fan_speed == 50) begin
    fan_pwm_out = 1;
  end else if (fan_speed == 75) begin
    fan_pwm_out = 1;
  end else if (fan_speed == 100) begin
    fan_pwm_out = 1;
  end else begin
    fan_pwm_out = 0;
  }

  // Output the PWM
  fan_pwm_out <= fan_pwm_out; // Keep it as is.

endalways

endmodule
