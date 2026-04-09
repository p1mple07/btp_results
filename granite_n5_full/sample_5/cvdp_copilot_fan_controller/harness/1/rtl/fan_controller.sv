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
);

reg [7:0] temp_low;              // Temperature threshold for low temperature
reg [7:0] temp_med;              // Temperature threshold for medium temperature
reg [7:0] temp_high;             // Temperature threshold for high temperature
reg [7:0] temp_adc_in;           // Simulated sensor data

always @(posedge clk) begin
    // Implement the functionality described in the problem description using appropriate logic and state machines. Make sure to handle all the mentioned aspects such as the APB interface, temperature-based fan speed control, PWM signal generation, and error handling.
end

endmodule