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

localparam TEMP_LOW = 25;
localparam TEMP_MED = 50;
localparam TEMP_HIGH = 75;

reg [7:0] temp_adc_in;
reg [7:0] fan_pwm_out;

always @(posedge clk) begin
    if(reset) begin
        temp_adc_in <= 0;
        fan_pwm_out <= 0;
    end else begin
        case(paddr)
            8'h0a : temp_adc_in <= pwdata; // temperature threshold for low temperature
            8'h0b : temp_adc_in <= pwdata; // temperature threshold for medium temperature
            8'h0c : temp_adc_in <= pwdata; // temperature threshold for high temperature
            default : begin
                pslverr <= 1; // indicates invalid address
            end
        endcase
    end
end

assign fan_pwm_out = (fan_pwm_out == 1)? 1'b1 : 1'b0;