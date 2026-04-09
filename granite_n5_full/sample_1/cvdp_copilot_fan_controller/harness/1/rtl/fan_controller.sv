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

    reg [7:0] temp_low;
    reg [7:0] temp_med;
    reg [7:0] temp_high;
    reg [7:0] temp_adc_in;
    
    reg [7:0] fan_pwm_out;
    
    always @(posedge clk) begin
        if (psel &&!penable) begin
            pslverr <= 0;
            case (paddr)
                8'h0a:
                    temp_low <= pwdata;
                    break;
                8'h0b:
                    temp_med <= pwdata;
                    break;
                8'h0c:
                    temp_high <= pwdata;
                    break;
                default:
                    pslverr <= 1;
                    break;
            endcase
        end else begin
            pslverr <= 0;
        end
    end
    
endmodule